vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ruler = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.cmd.colorscheme("lunaperche") 

vim.g.mapleader = " "

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return { vim.fn.getreg('"'), vim.fn.getregtype('"') }
    end,
    ["*"] = function()
      return { vim.fn.getreg('"'), vim.fn.getregtype('"') }
    end,
  },
}


vim.pack.add({
  { src="https://github.com/lewis6991/gitsigns.nvim", version="v2.1.0" },
  { src="https://github.com/Saghen/blink.cmp", version = 'v1.10.2'},
  { src="https://github.com/theprimeagen/harpoon", branch ="master" },
  { src="https://github.com/nvim-lua/plenary.nvim", branch ="master" },
  { src="https://github.com/nvim-telescope/telescope.nvim", version="v0.2.2" }
})

git = require('gitsigns').setup {
  signs = {
    add          = { text = '┃+' },
    change       = { text = '┃~' },
    delete       = { text = '┃-' },
    topdelete    = { text = '┃‾' },
    changedelete = { text = '┃_' },
    untracked    = { text = '┃┆' },
  },
  signs_staged = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '-' },
    topdelete    = { text = '‾' },
    changedelete = { text = '_' },
    untracked    = { text = '┆' },
  },
  signs_staged_enable = true,
  signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    follow_files = true
  },
  auto_attach = true,
  attach_to_untracked = false,
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 200,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
}

autocomplete = require("blink.cmp").setup({
  keymap = { preset = "default" },
  signature = { enabled = true },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
  },
  sources = {
    default = { "lsp", "path", "buffer" },
  },
})


local telescope = require('telescope.builtin')
vim.keymap.set("n", "<leader>ff", telescope.find_files, {})
vim.keymap.set("n", "<leader>fb", telescope.buffers, {})


local path = vim.env.NVIM_DEVCONTAINER_CONFIG
if path and vim.fn.filereadable(path) == 1 then
    dofile(path)
end
