local M = {}
local health = vim.health or require("health")
local config = require("gitlab-snippets.config")
local api = require("gitlab-snippets.api")

-- Start and report functions for compatibility with Neovim versions
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local error = health.error or health.report_error
local warn = health.warn or health.report_warn

-- Health check function
M.check = function()
	start("GitLab Snippets")

	-- Check if plenary is installed
	if not pcall(require, "plenary") then
		error("plenary.nvim is required but not installed")
	else
		ok("plenary.nvim is installed")
	end

	-- Check if telescope is installed
	if not pcall(require, "telescope") then
		error("telescope.nvim is required but not installed")
	else
		ok("telescope.nvim is installed")
	end

	-- Check OS
	local os_name = vim.loop.os_uname().sysname
	if os_name == "Darwin" then
		local arch = vim.loop.os_uname().machine
		if arch == "arm64" then
			ok("Running on supported platform: macOS ARM")
		else
			warn("Running on macOS but not on ARM architecture: " .. arch)
		end
	else
		warn("Running on unsupported OS: " .. os_name .. ". Only macOS ARM is officially supported.")
	end

	-- Check Neovim version
	local nvim_version = vim.version()
	local version_str = nvim_version.major .. "." .. nvim_version.minor .. "." .. nvim_version.patch
	if nvim_version.major == 0 and nvim_version.minor >= 10 then
		ok("Neovim version is compatible: " .. version_str)
	else
		warn("Neovim version is " .. version_str .. ", but 0.10.x or higher is recommended")
	end

	-- Check GitLab instances configuration
	local instances = config.options.instances
	if not instances or vim.tbl_isempty(instances) then
		warn("No GitLab instances configured")
	else
		ok(string.format("%d GitLab instance(s) configured", vim.tbl_count(instances)))

		-- Check tokens for each instance
		for name, _ in pairs(instances) do
			local token_var = "GITLAB_SNIPPETS_TOKEN_" .. string.upper(name)
			local token = os.getenv(token_var)
			if not token then
				token = os.getenv("GITLAB_SNIPPETS_TOKEN")
				if not token then
					warn(
						string.format(
							"No token found for instance '%s'. Expected in %s or GITLAB_SNIPPETS_TOKEN",
							name,
							token_var
						)
					)
				else
					ok(string.format("Using GITLAB_SNIPPETS_TOKEN for instance '%s'", name))
				end
			else
				ok(string.format("Token found for instance '%s' in %s", name, token_var))
			end

			-- Test connection to the instance
			local success, message = api.test_connection(name)
			if success then
				ok(string.format("Successfully connected to GitLab instance '%s'", name))
			else
				error(string.format("Failed to connect to GitLab instance '%s': %s", name, message or "Unknown error"))
			end
		end
	end
end

-- Return the module
return M
