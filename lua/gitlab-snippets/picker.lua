local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local api = require("gitlab-snippets.api")

-- State management for preview mode
local preview_state = {}

-- Helper function to determine snippet type from URL
local function get_snippet_type_from_url(url)
  if url and string.match(url, "/projects/%d+/snippets/") then
    return "project"
  end
  return "personal"
end

-- Helper function to get snippet content
local function get_snippet_content(instance_name, snippet)
  local content, err

  -- Use snippet_type if available, otherwise detect from URL
  if snippet.snippet_type == "project" or get_snippet_type_from_url(snippet.web_url) == "project" then
    content, err = api.get_project_snippet_content(instance_name, snippet.project_id, snippet.id)
  else
    content, err = api.get_snippet_content(instance_name, snippet.id)
  end

  if not content then
    vim.notify("Failed to fetch snippet content: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return nil
  end

  return content
end

-- Helper function to get snippet metadata
local function get_snippet_metadata(instance_name, snippet)
  local metadata, err

  -- Use snippet_type if available, otherwise detect from URL
  if snippet.snippet_type == "project" or get_snippet_type_from_url(snippet.web_url) == "project" then
    metadata, err = api.get_project_snippet(instance_name, snippet.project_id, snippet.id)
  else
    metadata, err = api.get_snippet(instance_name, snippet.id)
  end

  if not metadata then
    vim.notify("Failed to fetch snippet metadata: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return nil
  end

  return metadata
end

-- Helper function to format snippet metadata for display
local function format_snippet_metadata(metadata)
  local lines = {}

  table.insert(lines, "# Snippet Metadata")
  table.insert(lines, "")

  -- Basic information
  table.insert(lines, "## Basic Information")
  table.insert(lines, "")
  table.insert(lines, "**ID:** " .. tostring(metadata.id or "N/A"))
  table.insert(lines, "**Title:** " .. (metadata.title or "N/A"))
  table.insert(lines, "**Filename:** " .. (metadata.file_name or "N/A"))
  table.insert(lines, "")

  -- Description
  table.insert(lines, "## Description")
  table.insert(lines, "")
  if metadata.description and metadata.description ~= "" then
    -- Split description into multiple lines if it's long
    local desc_lines = vim.split(metadata.description, "\n")
    for _, line in ipairs(desc_lines) do
      table.insert(lines, line)
    end
  else
    table.insert(lines, "*No description available*")
  end
  table.insert(lines, "")

  -- Author information
  table.insert(lines, "## Author")
  table.insert(lines, "")
  if metadata.author then
    table.insert(lines, "**Name:** " .. (metadata.author.name or "N/A"))
    table.insert(lines, "**Username:** " .. (metadata.author.username or "N/A"))
    table.insert(lines, "**Email:** " .. (metadata.author.email or "N/A"))
    table.insert(lines, "**State:** " .. (metadata.author.state or "N/A"))
  else
    table.insert(lines, "*No author information available*")
  end
  table.insert(lines, "")

  -- Timestamps
  table.insert(lines, "## Timestamps")
  table.insert(lines, "")
  table.insert(lines, "**Created:** " .. (metadata.created_at or "N/A"))
  table.insert(lines, "**Updated:** " .. (metadata.updated_at or "N/A"))
  table.insert(lines, "")

  -- URLs
  table.insert(lines, "## URLs")
  table.insert(lines, "")
  table.insert(lines, "**Web URL:** [" .. (metadata.web_url or "N/A") .. "](" .. (metadata.web_url or "") .. ")")
  table.insert(lines, "**Raw URL:** [" .. (metadata.raw_url or "N/A") .. "](" .. (metadata.raw_url or "") .. ")")
  table.insert(lines, "")

  -- Additional information
  table.insert(lines, "## Additional Information")
  table.insert(lines, "")
  if metadata.project_id then
    table.insert(lines, "**Project ID:** " .. tostring(metadata.project_id))
  end
  table.insert(lines, "**Imported:** " .. tostring(metadata.imported or false))
  if metadata.imported_from then
    table.insert(lines, "**Imported From:** " .. metadata.imported_from)
  end

  return lines
end

-- Custom previewer for GitLab snippets with metadata toggle
local snippet_previewer = function(instance_name)
  return previewers.new_buffer_previewer({
    title = "Snippet Preview",
    define_preview = function(self, entry)
      local snippet = entry.value
      local preview_key = instance_name .. "_" .. snippet.id

      -- Initialize preview state if not exists
      if preview_state[preview_key] == nil then
        preview_state[preview_key] = "content" -- default to content view
      end

      if preview_state[preview_key] == "metadata" then
        -- Show metadata
        local metadata = get_snippet_metadata(instance_name, snippet)
        if not metadata then
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Failed to load snippet metadata" })
          return
        end

        local formatted_lines = format_snippet_metadata(metadata)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, formatted_lines)

        -- Set filetype to markdown for better readability
        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")

        -- Ensure syntax highlighting is enabled for this buffer
        vim.api.nvim_buf_call(self.state.bufnr, function()
          vim.cmd("syntax enable")
          vim.cmd("setlocal conceallevel=2") -- Enable URL concealing for better link display
        end)
      else
        -- Show content (default)
        local content = get_snippet_content(instance_name, snippet)
        if not content then
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Failed to load snippet content" })
          return
        end

        -- Set the content
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(content, "\n"))

        -- Try to set filetype based on filename
        local ext = snippet.file_name:match("%.([^%.]+)$")
        if ext then
          -- Special handling for yml files
          if ext == "yml" then
            vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "yaml")
          else
            vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", ext)
          end
        end
      end
    end,
  })
end

-- Pick GitLab instance
M.pick_instance = function(opts)
  opts = opts or {}

  local instances = api.list_instances()

  if #instances == 0 then
    vim.notify("No GitLab instances configured", vim.log.levels.ERROR)
    return
  end

  pickers
      .new(opts, {
        prompt_title = "GitLab Instances",
        finder = finders.new_table({
          results = instances,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.name .. " (" .. entry.url .. ")",
              ordinal = entry.name,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            M.pick_snippet_type(selection.value.name, opts)
          end)
          return true
        end,
      })
      :find()
end

-- Pick project
M.pick_project = function(instance_name, opts)
  opts = opts or {}

  local projects, err = api.list_projects(instance_name)
  if not projects then
    vim.notify("Failed to fetch projects: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  if #projects == 0 then
    vim.notify("No projects found for this user", vim.log.levels.INFO)
    return
  end

  pickers
      .new(opts, {
        prompt_title = "Select Project from " .. instance_name,
        finder = finders.new_table({
          results = projects,
          entry_maker = function(entry)
            local display_text = entry.name_with_namespace or entry.name
            return {
              value = entry,
              display = display_text,
              ordinal = display_text,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            M.pick_project_snippets(instance_name, selection.value, opts)
          end)
          return true
        end,
      })
      :find()
end

-- Pick project snippets
M.pick_project_snippets = function(instance_name, project, opts)
  opts = opts or {}

  local snippets, err = api.list_project_snippets(instance_name, project.id)
  if not snippets then
    vim.notify("Failed to fetch snippets for project: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  if #snippets == 0 then
    vim.notify("No snippets found in project " .. project.name, vim.log.levels.INFO)
    return
  end

  -- Mark snippets as project type and add project_id
  for _, snippet in ipairs(snippets) do
    snippet.snippet_type = "project"
    snippet.project_id = project.id
  end

  M.display_snippets(instance_name, snippets, "Project Snippets: " .. project.name, opts)
end

-- Pick snippet type
M.pick_snippet_type = function(instance_name, opts)
  opts = opts or {}

  local types = {
    { id = "user",    display = "Your Snippets" },
    { id = "public",  display = "Public Snippets" },
    { id = "all",     display = "All Snippets (Admin)" },
    { id = "project", display = "Project Snippets" },
  }

  pickers
      .new(opts, {
        prompt_title = "Snippet Type",
        finder = finders.new_table({
          results = types,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.display,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            local type_id = selection.value.id

            if type_id == "user" then
              M.pick_user_snippets(instance_name, opts)
            elseif type_id == "public" then
              M.pick_public_snippets(instance_name, opts)
            elseif type_id == "all" then
              M.pick_all_snippets(instance_name, opts)
            elseif type_id == "project" then
              M.pick_project(instance_name, opts)
            end
          end)
          return true
        end,
      })
      :find()
end

-- Pick user snippets
M.pick_user_snippets = function(instance_name, opts)
  opts = opts or {}

  local snippets, err = api.list_user_snippets(instance_name)
  if not snippets then
    vim.notify("Failed to fetch personal snippets: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  if #snippets == 0 then
    vim.notify("No personal snippets found", vim.log.levels.INFO)
    return
  end

  -- Mark snippets as personal
  if type(snippets) == "table" then
    for _, snippet in ipairs(snippets) do
      snippet.snippet_type = "personal"
    end
  end
  M.display_snippets(instance_name, snippets, "Your Snippets", opts)
end

-- Pick public snippets
M.pick_public_snippets = function(instance_name, opts)
  opts = opts or {}

  local snippets, err = api.list_public_snippets(instance_name)
  if not snippets then
    vim.notify("Failed to fetch public snippets: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  if #snippets == 0 then
    vim.notify("No public snippets found", vim.log.levels.INFO)
    return
  end

  -- Mark snippets as public
  if type(snippets) == "table" then
    for _, snippet in ipairs(snippets) do
      snippet.snippet_type = "public"
    end
  end

  M.display_snippets(instance_name, snippets, "Public Snippets", opts)
end

-- Pick all snippets
M.pick_all_snippets = function(instance_name, opts)
  opts = opts or {}

  local snippets, err = api.list_all_snippets(instance_name)
  if not snippets then
    vim.notify("Failed to fetch all snippets: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  if #snippets == 0 then
    vim.notify("No snippets found in the instance", vim.log.levels.INFO)
    return
  end

  -- Mark snippets based on their type
  if type(snippets) == "table" then
    for _, snippet in ipairs(snippets) do
      snippet.snippet_type = get_snippet_type_from_url(snippet.web_url)
    end
  end

  M.display_snippets(instance_name, snippets, "All Snippets", opts)
end

-- Display snippets in Telescope with automatic preview
M.display_snippets = function(instance_name, snippets, title, opts)
  opts = opts or {}

  pickers
      .new(opts, {
        prompt_title = title
            .. " from "
            .. instance_name
            .. " | Enter: Toggle Metadata | Ctrl+I: Insert | Ctrl+N: New Buffer",
        finder = finders.new_table({
          results = snippets,
          entry_maker = function(entry)
            local display_name = entry.title
            if entry.file_name and entry.file_name ~= "" then
              display_name = display_name .. " (" .. entry.file_name .. ")"
            end

            -- Add author info if available
            if entry.author and entry.author.name then
              display_name = display_name .. " - by " .. entry.author.name
            end

            -- Add snippet type indicator
            local type_indicator = entry.snippet_type or "unknown"
            display_name = display_name .. " [" .. type_indicator .. "]"

            return {
              value = entry,
              display = display_name,
              ordinal = entry.title,
            }
          end,
        }),
        sorter = conf.generic_sorter(opts),
        previewer = snippet_previewer(instance_name),
        attach_mappings = function(prompt_bufnr, map)
          -- Default action (Enter) - toggle between content and metadata preview
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if selection then
              local snippet = selection.value
              local preview_key = instance_name .. "_" .. snippet.id

              -- Toggle preview state
              if preview_state[preview_key] == "metadata" then
                preview_state[preview_key] = "content"
              else
                preview_state[preview_key] = "metadata"
              end

              -- Force refresh the preview
              -- Using a method that's compatible with Telescope's architecture
              -- This triggers a redraw of the current selection's preview
              actions.move_selection_next(prompt_bufnr)
              actions.move_selection_previous(prompt_bufnr)
            end
          end)

          -- Ctrl+I - insert snippet at cursor
          map("i", "<C-i>", function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              M.insert_snippet(instance_name, selection.value)
            end
          end)

          map("n", "<C-i>", function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              M.insert_snippet(instance_name, selection.value)
            end
          end)

          -- Ctrl+N - open snippet in new buffer
          map("i", "<C-n>", function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              M.open_snippet_in_buffer(instance_name, selection.value)
            end
          end)

          map("n", "<C-n>", function()
            local selection = action_state.get_selected_entry()
            if selection then
              actions.close(prompt_bufnr)
              M.open_snippet_in_buffer(instance_name, selection.value)
            end
          end)

          return true
        end,
      })
      :find()
end

-- Insert snippet at cursor
M.insert_snippet = function(instance_name, snippet)
  local content = get_snippet_content(instance_name, snippet)
  if not content then
    return
  end

  -- Insert at cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]

  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_text(bufnr, row, col, row, col, lines)

  vim.notify("Inserted snippet: " .. snippet.title, vim.log.levels.INFO)
end

-- Open snippet in new buffer
M.open_snippet_in_buffer = function(instance_name, snippet)
  local content = get_snippet_content(instance_name, snippet)
  if not content then
    return
  end

  -- Create new buffer
  vim.cmd("enew")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))

  -- Set buffer name if filename is available
  if snippet.file_name and snippet.file_name ~= "" then
    vim.cmd("file " .. vim.fn.fnameescape(snippet.file_name))

    -- Try to set filetype based on filename
    local ext = snippet.file_name:match("%.([^%.]+)$")
    if ext then
      vim.api.nvim_buf_set_option(bufnr, "filetype", ext)
    end
  else
    vim.cmd("file Snippet-" .. snippet.id)
  end

  vim.notify("Opened snippet in new buffer: " .. snippet.title, vim.log.levels.INFO)
end

return M
