local M = {}

-- Default configuration
M.defaults = {
	-- List of GitLab instances
	instances = {},
	-- Default action for snippets (insert or new_file)
	default_action = "insert",
}

-- Current configuration
M.options = {}

-- Setup function
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

-- Get instance configuration by name
M.get_instance = function(name)
	return M.options.instances[name]
end

-- Return the module
return M
