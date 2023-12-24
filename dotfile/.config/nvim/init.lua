local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=v10.15.1",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("general")	
require("lazy").setup({
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		priority = 1000,

		build = ":TSUpdate",
		tag = "v0.9.1",
		config = function()
			local configs = require("nvim-treesitter.configs")

      			configs.setup({
          			ensure_installed = { 
					"c", "lua", "vim", "vimdoc", "javascript", 
					"html", "cpp", "jsonc", "rust", "nix", "rust",
			 		"python", "typescript", "json", "yaml", 
					"go", "c_sharp", "dockerfile", "css", "cmake", "markdown", 
					"markdown_inline"},
          			sync_install = false,
          			highlight = { enable = true },
          			indent = { enable = true },  
        		})
    		end
	}
})

