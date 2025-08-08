local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local picker = require("gitlab-snippets.picker")

return telescope.register_extension({
	exports = {
		gitlab_snippets = picker.pick_instance,
	},
})
