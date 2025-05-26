local M = {}

-- Setup function to initialize the plugin
M.setup = function(opts)
  -- Import configuration module and set user config
  require("gitlab-snippets.config").setup(opts)

  -- Set up commands
  vim.api.nvim_create_user_command("GitLabSnippets", function()
    require("gitlab-snippets.picker").pick_instance()
  end, {})
end

-- Health check function for :checkhealth
M.health = function()
  require("gitlab-snippets.health").check()
end

-- Expose picker functionality
M.pick_instance = function(opts)
  require("gitlab-snippets.picker").pick_instance(opts)
end

-- Return the module
return M
