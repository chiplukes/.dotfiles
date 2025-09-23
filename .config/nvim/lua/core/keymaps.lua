-- lua/core/keymaps.lua
-- All custom keybindings centralized
local M = {}

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
-- See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Ensure <Esc> works in insert mode across environments/plugins. Some
-- plugins or terminal layers can cause the literal <Esc> key to be
-- intercepted; mapping it to <C-c> is a safe, standard fallback that
-- reliably leaves insert mode. This is intentionally defensive.
vim.cmd([[inoremap <Esc> <C-c>]])

-- Diagnostic keymaps (will be overridden below with your custom mappings)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- =============================================================================
-- VSCode-style keybindings to maintain muscle memory
-- =============================================================================

-- Command Palette equivalent
vim.keymap.set('n', '<leader>cp', function() require('snacks').picker.commands() end, { desc = '[C]ommand [P]alette' })

-- Quick file open (like Ctrl+P in VSCode)
vim.keymap.set('n', '<leader>o', function() require('snacks').picker.files() end, { desc = '[O]pen file picker' })

-- Find in project (matching your VS Code <leader>f)
vim.keymap.set('n', '<leader>ff', function() require('snacks').picker.grep() end, { desc = '[F]ind in project (your VS Code mapping)' })

-- Window management (matching VSCode leader+w combinations)
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = '[W]indow split [V]ertical' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<CR>', { desc = '[W]indow [C]lose' })
vim.keymap.set('n', '<leader>wf', '<cmd>only<CR>', { desc = '[W]indow [F]ullscreen (close others)' })
vim.keymap.set('n', '<leader>we', '<cmd>Explore<CR>', { desc = '[W]indow [E]xplorer (netrw)' })

-- Context menu equivalent
vim.keymap.set('n', '<leader>cm', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = '[C]ontext [M]enu (code actions)' })

-- Quick fix keybindings (matching your VS Code custom setup)
-- Note: These will work when code action menu is visible
vim.keymap.set('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix (VS Code Ctrl+.)' })
vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix (leader alternative)' })
vim.keymap.set('v', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix selection' })

-- Your custom navigation keybindings
vim.keymap.set('n', '<A-h>', '<cmd>bprevious<CR>', { desc = 'Previous editor/tab (your Alt+H)' })
vim.keymap.set('n', '<A-l>', '<cmd>bnext<CR>', { desc = 'Next editor/tab (your Alt+L)' })

-- Diagnostic navigation (matching your 'ge' mapping)
vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, { desc = '[G]o to next [E]rror (your VS Code mapping)' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic' })

-- Diagnostic details
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Hover information (like VSCode gh)
vim.keymap.set('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', { desc = '[G]o [H]hover info' })

-- Go to symbol/outline (like VSCode go)
vim.keymap.set('n', 'go', function() vim.lsp.buf.document_symbol() end, { desc = '[G]o to [O]utline/symbols' })

-- Multi-cursor simulation with visual block and substitution
vim.keymap.set('v', '<leader>ca', '<cmd>s/\\%V\\(\\S\\+\\)/&/g<CR>', { desc = '[C]ursor [A]ll (select all in visual)' })

-- Paste from yank register (like VSCode leader+p)
vim.keymap.set('n', '<leader>p', '"0p', { desc = '[P]aste from yank register' })

-- Window navigation (standard Neovim Ctrl+hjkl works by default)
-- Use Alt+j/k for vertical window movement to complement Alt+h/l buffer nav
vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- EasyMotion-style movement (matching VSCode 's' mapping) - Flash.nvim will override this
vim.keymap.set('n', 's', function() require('flash').jump() end, { desc = 'Flash [S]earch and jump' })

-- =============================================================================
-- Completion keybindings (matching your VS Code custom setup)
-- =============================================================================
-- Note: Completion keybindings are configured in blink.cmp setup below
-- These exactly match your VS Code keybindings:
-- - Ctrl+Space: Trigger/show completion
-- - Ctrl+N: Next suggestion (in both completion and code action menus)
-- - Ctrl+P: Previous suggestion (in both completion and code action menus)
-- - Ctrl+Y: Accept suggestion (in both completion and code action menus)
-- - Ctrl+U: Hide suggestion widget

-- =============================================================================
-- Bookmark functionality (matching VSCode bookmarks extension)
-- =============================================================================
-- Note: We'll use Neovim's built-in marks enhanced with custom functions
-- This provides similar functionality to VSCode bookmarks

-- Toggle bookmark at current line
vim.keymap.set('n', '<leader>mm', function()
  -- Get next available mark (a-z)
  local marks = vim.split(vim.fn.execute('marks'), '\n')
  local used_marks = {}
  for _, line in ipairs(marks) do
    local mark = line:match('^%s*([a-z])')
    if mark then used_marks[mark] = true end
  end

  -- Find first unused mark
  for i = string.byte('a'), string.byte('z') do
    local mark = string.char(i)
    if not used_marks[mark] then
      vim.cmd('mark ' .. mark)
      print('Bookmark set: ' .. mark)
      return
    end
  end
  print('No available bookmark slots')
end, { desc = '[M]ark/Bookmark toggle' })

-- List all bookmarks
vim.keymap.set('n', '<leader>ml', '<cmd>marks<CR>', { desc = '[M]ark [L]ist bookmarks' })

-- Jump to next mark (approximate bookmark navigation)
vim.keymap.set('n', '<leader>mn', function()
  vim.cmd("normal! ]'")
end, { desc = '[M]ark [N]ext bookmark' })

-- Jump to previous mark (approximate bookmark navigation)
vim.keymap.set('n', '<leader>mp', function()
  vim.cmd("normal! ['")
end, { desc = '[M]ark [P]revious bookmark' })

-- =============================================================================
-- Formatting and Code Actions (matching VSCode patterns)
-- =============================================================================

-- Format document (like VSCode leader+rf)
vim.keymap.set('n', '<leader>rf', function()
  vim.lsp.buf.format({ async = true })
end, { desc = '[R]ecode [F]ormat document' })

-- Format selection in visual mode
vim.keymap.set('v', '<leader>rf', function()
  vim.lsp.buf.format({ async = true })
end, { desc = '[R]ecode [F]ormat selection' })

-- Accept/commit suggestions (like VSCode leader+y)
vim.keymap.set('n', '<leader>y', function()
  -- This will be enhanced when we add Copilot, for now use LSP code actions
  vim.lsp.buf.code_action()
end, { desc = '[Y]es/Accept suggestions' })

-- Hide/dismiss suggestions (like VSCode leader+u)
vim.keymap.set('n', '<leader>u', '<cmd>lua vim.diagnostic.hide()<CR>', { desc = '[U]ndo/Hide suggestions/diagnostics' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

return M
