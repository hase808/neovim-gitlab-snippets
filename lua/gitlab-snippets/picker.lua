local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local api = require("gitlab-snippets.api")

-- Helper function to determine snippet type from URL
local function get_snippet_type_from_url(url)
  if url and string.match(url, "/projects/%d+/snippets/") then
    return "project"
  end
  return "personal"
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
              vim.notify("Project snippets not yet implemented", vim.log.levels.WARN)
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

-- Display snippets in Telescope
M.display_snippets = function(instance_name, snippets, title, opts)
  opts = opts or {}

  pickers
      .new(opts, {
        prompt_title = title .. " from " .. instance_name,
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
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            M.handle_snippet_selection(instance_name, selection.value)
          end)
          return true
        end,
      })
      :find()
end

-- Handle selected snippet
M.handle_snippet_selection = function(instance_name, snippet)
  local actions_menu = {
    { id = "preview",    display = "Preview" },
    { id = "insert",     display = "Insert at cursor" },
    { id = "new_buffer", display = "Open in new buffer" },
  }

  pickers
      .new({}, {
        prompt_title = "Action for " .. snippet.title,
        finder = finders.new_table({
          results = actions_menu,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.display,
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)

            local action_id = selection.value.id

            if action_id == "preview" then
              M.preview_snippet(instance_name, snippet)
            elseif action_id == "insert" then
              M.insert_snippet(instance_name, snippet)
            elseif action_id == "new_buffer" then
              M.open_snippet_in_buffer(instance_name, snippet)
            end
          end)
          return true
        end,
      })
      :find()
end

-- Preview snippet
M.preview_snippet = function(instance_name, snippet)
  local content, err

  -- Use snippet_type if available, otherwise detect from URL
  if snippet.snippet_type == "project" or get_snippet_type_from_url(snippet.web_url) == "project" then
    content, err = api.get_project_snippet_content(instance_name, snippet.project_id, snippet.id)
  else
    content, err = api.get_snippet_content(instance_name, snippet.id)
  end

  if not content then
    vim.notify("Failed to fetch snippet content: " .. (err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  -- Create a temporary buffer for preview
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(content, "\n"))

  -- Set buffer name
  local title = string.format("Snippet Preview [%s]: %s", snippet.snippet_type or "unknown", snippet.title)
  if snippet.file_name and snippet.file_name ~= "" then
    vim.api.nvim_buf_set_name(bufnr, snippet.file_name)
  else
    vim.api.nvim_buf_set_name(bufnr, title)
  end

  -- Try to set filetype based on filename
  if snippet.file_name and snippet.file_name ~= "" then
    local ext = snippet.file_name:match("%.([^%.]+)$")
    if ext then
      vim.api.nvim_buf_set_option(bufnr, "filetype", ext)
    end
  end

  -- Open buffer in a split
  vim.cmd("split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)

  -- Make it temporary
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  vim.notify("Previewing snippet: " .. snippet.title, vim.log.levels.INFO)
end

-- Insert snippet at cursor
M.insert_snippet = function(instance_name, snippet)
  local content, err

  -- Use snippet_type if available, otherwise detect from URL
  if snippet.snippet_type == "project" or get_snippet_type_from_url(snippet.web_url) == "project" then
    content, err = api.get_project_snippet_content(instance_name, snippet.project_id, snippet.id)
  else
    content, err = api.get_snippet_content(instance_name, snippet.id)
  end

  if not content then
    vim.notify("Failed to fetch snippet content: " .. (err or "Unknown error"), vim.log.levels.ERROR)
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
  local content, err

  -- Use snippet_type if available, otherwise detect from URL
  if snippet.snippet_type == "project" or get_snippet_type_from_url(snippet.web_url) == "project" then
    content, err = api.get_project_snippet_content(instance_name, snippet.project_id, snippet.id)
  else
    content, err = api.get_snippet_content(instance_name, snippet.id)
  end

  if not content then
    vim.notify("Failed to fetch snippet content: " .. (err or "Unknown error"), vim.log.levels.ERROR)
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
