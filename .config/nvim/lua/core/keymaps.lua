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


-- -- reload Neovim Config - not supported wtih lazy.nvim
-- vim.keymap.set('n', '<leader>rc', '<cmd>luafile $MYVIMRC<CR>', { desc = '[R]eload Neovim [C]onfig' })


-- =============================================================================
-- VSCode-style keybindings to maintain muscle memory
-- =============================================================================

-- Command Palette equivalent
vim.keymap.set('n', '<leader>cp', function() require('snacks').picker.commands() end, { desc = '[C]ommand [P]alette' })

-- Quick file open (like Ctrl+P in VSCode)
vim.keymap.set('n', '<leader>of', function() require('snacks').picker.files() end, { desc = '[O]pen file picker' })

-- Find in project (matching your VS Code <leader>f)
vim.keymap.set('n', '<leader>ff', function() require('snacks').picker.grep() end, { desc = '[F]ind in project (your VS Code mapping)' })

-- Window management (matching VSCode leader+w combinations)
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = '[W]indow split [V]ertical' })
vim.keymap.set('n', '<leader>wc', '<cmd>close<CR>', { desc = '[W]indow [C]lose' })
vim.keymap.set('n', '<leader>wf', '<cmd>only<CR>', { desc = '[W]indow [F]ullscreen (close others)' })
vim.keymap.set('n', '<leader>we', '<cmd>Explore<CR>', { desc = '[W]indow [E]xplorer (netrw)' })
-- Window navigation (standard Neovim Ctrl+hjkl works by default)
-- Use Alt+j/k for vertical window movement to complement Alt+h/l buffer nav
vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Move to window left, or to previous tab if no left window exists
-- Move to window left, or to previous tab; wrap to last tab if at first
vim.keymap.set('n', '<A-h>', function()
  local cur = vim.fn.winnr()
  local left = vim.fn.winnr('h')
  if left ~= cur then
    vim.cmd('wincmd h')
    -- sync persistent flat index with new window position
    local function sync_flat_idx_to_current()
      local tabs = vim.fn.tabpagenr('$')
      local entries = {}
      for t = 1, tabs do
        local wins = vim.api.nvim_tabpage_list_wins(t)
        for _, w in ipairs(wins) do
          table.insert(entries, { tab = t, win = w })
        end
      end
      if #entries == 0 then
        _G._flat_nav_idx = nil
        _G._flat_nav_size = 0
        return
      end
      local cur_tab = vim.fn.tabpagenr()
      local cur_win = vim.api.nvim_get_current_win()
      for i, e in ipairs(entries) do
        if e.tab == cur_tab and e.win == cur_win then
          _G._flat_nav_idx = i
          _G._flat_nav_size = #entries
          return
        end
      end
      -- fallback: set to first entry in current tab if possible
      for i, e in ipairs(entries) do
        if e.tab == cur_tab then
          _G._flat_nav_idx = i
          _G._flat_nav_size = #entries
          return
        end
      end
      _G._flat_nav_idx = 1
      _G._flat_nav_size = #entries
    end
    pcall(sync_flat_idx_to_current)
    return
  end
  -- No window to the left: build a flattened (tab,buf) list and move to the previous entry
  local function prev_in_flat_list()
    local tabs = vim.fn.tabpagenr('$')
    local entries = {}
    for t = 1, tabs do
      local wins = vim.api.nvim_tabpage_list_wins(t)
      for _, w in ipairs(wins) do
        table.insert(entries, { tab = t, win = w })
      end
    end
    if #entries == 0 then return end

    -- initialize persistent index if missing or size changed
    if _G._flat_nav_idx == nil or (_G._flat_nav_size or 0) ~= #entries then
      _G._flat_nav_idx = 1
      _G._flat_nav_size = #entries
      -- attempt to align with current window
      local cur_tab = vim.fn.tabpagenr()
      local cur_win = vim.api.nvim_get_current_win()
      for i, e in ipairs(entries) do
        if e.tab == cur_tab and e.win == cur_win then _G._flat_nav_idx = i; break end
      end
    end

    _G._flat_nav_idx = (_G._flat_nav_idx - 2) % #entries + 1
    local target = entries[_G._flat_nav_idx]
    local cur_tab = vim.fn.tabpagenr()
    if target.tab ~= cur_tab then
      vim.cmd('tabnext ' .. tostring(target.tab))
      -- focus the window instance directly
      pcall(vim.api.nvim_set_current_win, target.win)
      return
    end
    pcall(vim.api.nvim_set_current_win, target.win)
  end

  prev_in_flat_list()
end, { desc = 'Window left or buffer previous, else wrap to previous/last tab' })

-- Move to window right, or to next tab; wrap to first tab if at last
vim.keymap.set('n', '<A-l>', function()
  local cur = vim.fn.winnr()
  local right = vim.fn.winnr('l')
  if right ~= cur then
    vim.cmd('wincmd l')
    -- sync persistent flat index with new window position
    local function sync_flat_idx_to_current()
      local tabs = vim.fn.tabpagenr('$')
      local entries = {}
      for t = 1, tabs do
        local wins = vim.api.nvim_tabpage_list_wins(t)
        for _, w in ipairs(wins) do
          table.insert(entries, { tab = t, win = w })
        end
      end
      if #entries == 0 then
        _G._flat_nav_idx = nil
        _G._flat_nav_size = 0
        return
      end
      local cur_tab = vim.fn.tabpagenr()
      local cur_win = vim.api.nvim_get_current_win()
      for i, e in ipairs(entries) do
        if e.tab == cur_tab and e.win == cur_win then
          _G._flat_nav_idx = i
          _G._flat_nav_size = #entries
          return
        end
      end
      -- fallback: set to first entry in current tab if possible
      for i, e in ipairs(entries) do
        if e.tab == cur_tab then
          _G._flat_nav_idx = i
          _G._flat_nav_size = #entries
          return
        end
      end
      _G._flat_nav_idx = 1
      _G._flat_nav_size = #entries
    end
    pcall(sync_flat_idx_to_current)
    return
  end
  -- No window to the right: build a flattened (tab,buf) list and move to the next entry
  local function next_in_flat_list()
    local tabs = vim.fn.tabpagenr('$')
    local entries = {}
    for t = 1, tabs do
      local wins = vim.api.nvim_tabpage_list_wins(t)
      for _, w in ipairs(wins) do
        table.insert(entries, { tab = t, win = w })
      end
    end
    if #entries == 0 then return end

    if _G._flat_nav_idx == nil or (_G._flat_nav_size or 0) ~= #entries then
      _G._flat_nav_idx = 0
      _G._flat_nav_size = #entries
      local cur_tab = vim.fn.tabpagenr()
      local cur_win = vim.api.nvim_get_current_win()
      for i, e in ipairs(entries) do
        if e.tab == cur_tab and e.win == cur_win then _G._flat_nav_idx = i; break end
      end
    end

    _G._flat_nav_idx = (_G._flat_nav_idx) % #entries + 1
    local target = entries[_G._flat_nav_idx]
    local cur_tab = vim.fn.tabpagenr()
    if target.tab ~= cur_tab then
      vim.cmd('tabnext ' .. tostring(target.tab))
      pcall(vim.api.nvim_set_current_win, target.win)
      return
    end
    pcall(vim.api.nvim_set_current_win, target.win)
  end

  next_in_flat_list()
end, { desc = 'Window right or buffer next, else wrap to next/first tab' })

-- -- Temporary debug mapping: print flattened entries and persistent index
-- vim.keymap.set('n', '<leader>td', function()
--   local tabs = vim.fn.tabpagenr('$')
--   local entries = {}
--   for t = 1, tabs do
--     local raw = vim.fn.tabpagebuflist(t)
--     if type(raw) ~= 'table' then raw = { raw } end
--     local seen = {}
--     for _, b in ipairs(raw) do
--       if type(b) == 'number' and vim.fn.buflisted(b) == 1 and not seen[b] then
--         table.insert(entries, { tab = t, buf = b, name = vim.fn.bufname(b) })
--         seen[b] = true
--       end
--     end
--   end
--   print('Flattened entries:')
--   local cur_tab = vim.fn.tabpagenr()
--   local cur_buf = vim.api.nvim_get_current_buf()
--   local matched = {}
--   for i, e in ipairs(entries) do
--     local mark = ''
--     if e.tab == cur_tab and e.buf == cur_buf then
--       mark = '<-- current'
--       table.insert(matched, i)
--     end
--     print(i, 'T' .. e.tab, 'buf=' .. tostring(e.buf), e.name, mark)
--   end
--   if #matched == 0 then
--     print('No matching entry for current tab+buf')
--   else
--     print('Matching indices for current entry:', table.concat(vim.tbl_map(tostring, matched), ', '))
--   end
--   print('Persistent idx:', vim.inspect(_G._flat_nav_idx), 'size:', vim.inspect(_G._flat_nav_size))
--   print('Current tab/buf:', cur_tab, cur_buf, vim.fn.bufname('%'))
-- end, { desc = 'Debug: show flat nav entries and index' })


-- Context menu equivalent
vim.keymap.set('n', '<leader>cm', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = '[C]ontext [M]enu (code actions)' })

-- Quick fix keybindings (matching your VS Code custom setup)
-- Note: These will work when code action menu is visible
vim.keymap.set('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix (VS Code Ctrl+.)' })
vim.keymap.set('n', '<leader>.', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix (leader alternative)' })
vim.keymap.set('v', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>', { desc = 'Quick fix selection' })

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

vim.keymap.set('n', '<leader>pr', '"0p', { desc = '[P]aste from yank register' })


-- EasyMotion-style movement (matching VSCode 's' mapping) - Flash.nvim will override this
--vim.keymap.set('n', 'sj', function() require('flash').jump() end, { desc = 'Flash [S]earch and jump' })

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
