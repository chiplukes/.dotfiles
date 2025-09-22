-- lua/core/keymaps.lua
local M = {}
local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode with easy shortcut
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Diagnostic keymaps
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- VSCode-style mappings and others can be moved here later

-- Defensive inoremap to ensure <Esc> exits insert mode reliably
vim.cmd([[inoremap <Esc> <C-c>]])

return M
