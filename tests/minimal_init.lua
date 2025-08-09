-- Minimal Neovim configuration for testing
local plenary_dir = os.getenv("PLENARY_DIR") or "~/.local/share/nvim/lazy/plenary.nvim"
local gitlab_snippets_dir = vim.fn.getcwd()

vim.opt.rtp:prepend(plenary_dir)
vim.opt.rtp:prepend(gitlab_snippets_dir)

require("plenary.busted")
