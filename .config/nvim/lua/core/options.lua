-- lua/core/options.lua
-- Migrate editor options from init.lua here
local M = {}

-- Basic UI
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Example options that you had in init.lua (add others as needed)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.o.clipboard = 'unnamedplus'

return M
