-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- vim.g.mapleader = " "
-- vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{
			"mason-org/mason.nvim",
			opts = { registries = { "github:mason-org/mason-registry", "github:zdelv/pyrefly-mason-registry" } },
		},
	},
	checker = { enabled = true },
})

-- Update Mason registry and install Pyrefly
local registry = require("mason-registry")
registry.refresh()
registry.get_package("pyrefly"):install()

-- Configure pyrefly's LSP (within nvim)
vim.lsp.config("pyrefly", {
	cmd = { "pyrefly", "lsp" },
	root_markers = { "pyproject.toml", "setup.py" },
	filetypes = { "python" },
})

-- Enable autostarting of the pyrefly LSP.
vim.lsp.enable("pyrefly")
