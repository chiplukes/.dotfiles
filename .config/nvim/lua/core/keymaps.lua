-- lua/core/keymaps.lua
-- All custom keybindings centralized
local M = {}

-- =============================================================================
-- Repeat Last Leader Command
-- =============================================================================

-- Global storage for the last executed leader command
_G.last_leader_cmd = nil

-- Wrapper function to remember and execute commands
function _G.run_and_remember(fn)
  _G.last_leader_cmd = fn
  fn()
end

-- Function to repeat the last leader command
function _G.repeat_last_leader()
  if _G.last_leader_cmd then
    _G.last_leader_cmd()
  else
    vim.notify('No previous leader command to repeat', vim.log.levels.WARN)
  end
end

-- Map leader+leader to repeat last leader command (changed from comma)
vim.keymap.set('n', '<leader><leader>', _G.repeat_last_leader, { desc = 'Repeat last leader command' })

-- =============================================================================
-- [[ Basic Keymaps ]]
-- =============================================================================
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
-- VIP Keymaps (No Category Prefix - Direct Access)
-- =============================================================================

-- Find files in project (VIP - most used)
vim.keymap.set('n', '<leader>ff', function()
  require('snacks').picker.grep()
end, { desc = 'Find in project' })

-- Show explorer (VIP)
vim.keymap.set('n', '<leader>se', function()
  require('snacks').picker.explorer()
end, { desc = 'Show explorer' })

-- Accept AI suggestion (VIP)
vim.keymap.set('n', '<leader>y', function()
  vim.lsp.buf.code_action()
end, { desc = 'Accept suggestion' })

-- Paste from yank register (VIP - repeatable)
vim.keymap.set('n', '<leader>pr', function()
  run_and_remember(function()
    vim.cmd('normal! "0p')
  end)
end, { desc = 'Paste from yank register' })

-- =============================================================================
-- Window Management (VIP - Alt keys)
-- =============================================================================

-- Window navigation (standard Neovim Ctrl+hjkl works by default)
-- Use Alt+j/k for vertical window movement to complement Alt+h/l buffer nav
vim.keymap.set('n', '<A-j>', '<C-w><C-j>', { desc = 'Window down' })
vim.keymap.set('n', '<A-k>', '<C-w><C-k>', { desc = 'Window up' })

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
    local tabpages = vim.api.nvim_list_tabpages()
    local entries = {}
    for _, tab_handle in ipairs(tabpages) do
      local tab_nr = vim.api.nvim_tabpage_get_number(tab_handle)
      local wins = vim.api.nvim_tabpage_list_wins(tab_handle)
      for _, w in ipairs(wins) do
        table.insert(entries, { tab = tab_nr, win = w })
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
    local tabpages = vim.api.nvim_list_tabpages()
    local entries = {}
    for _, tab_handle in ipairs(tabpages) do
      local tab_nr = vim.api.nvim_tabpage_get_number(tab_handle)
      local wins = vim.api.nvim_tabpage_list_wins(tab_handle)
      for _, w in ipairs(wins) do
        table.insert(entries, { tab = tab_nr, win = w })
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


-- =============================================================================
-- 🔍 Search Category (<leader>s)
-- =============================================================================

-- Search files
vim.keymap.set('n', '<leader>sf', function()
  require('snacks').picker.files()
end, { desc = 'Search files' })

-- Recent files
vim.keymap.set('n', '<leader>sr', function()
  require('snacks').picker.recent()
end, { desc = 'Recent files' })

-- Config files
vim.keymap.set('n', '<leader>sc', function()
  require('snacks').picker.files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Config files' })

-- Search by grep
vim.keymap.set('n', '<leader>sg', function()
  require('snacks').picker.grep()
end, { desc = 'Search by grep' })

-- Search current word
vim.keymap.set('n', '<leader>sw', function()
  require('snacks').picker.grep_word()
end, { desc = 'Search current word' })

-- Search in buffer
vim.keymap.set('n', '<leader>s/', function()
  require('snacks').picker.lines()
end, { desc = 'Search in buffer' })

-- Search in open files
vim.keymap.set('n', '<leader>sof', function()
  require('snacks').picker.grep_open()
end, { desc = 'Search in open files' })

-- Smart search
vim.keymap.set('n', '<leader>ss', function()
  require('snacks').picker.smart()
end, { desc = 'Smart search' })

-- Search keymaps
vim.keymap.set('n', '<leader>sk', function()
  require('snacks').picker.keymaps()
end, { desc = 'Search keymaps' })

-- Search help
vim.keymap.set('n', '<leader>sh', function()
  require('snacks').picker.help()
end, { desc = 'Search help' })

-- Search diagnostics
vim.keymap.set('n', '<leader>sd', function()
  require('snacks').picker.diagnostics()
end, { desc = 'Search diagnostics' })

-- Resume search
vim.keymap.set('n', '<leader>sr', function()
  require('snacks').picker.resume()
end, { desc = 'Resume search' })

-- Buffer list
vim.keymap.set('n', '<leader>sbl', function()
  require('snacks').picker.buffers()
end, { desc = 'Buffer list' })

-- Command palette
vim.keymap.set('n', '<leader>sp', function()
  require('snacks').picker.commands()
end, { desc = 'Command palette' })

-- =============================================================================
-- 🪟 Window Management (<leader>w)
-- =============================================================================

-- Split vertical
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Split vertical' })

-- Move window to new tab (using built-in Vim command)
vim.keymap.set('n', '<leader>wt', '<C-w>T', { desc = 'Move window to new tab' })

-- Close window
vim.keymap.set('n', '<leader>wc', '<cmd>close<CR>', { desc = 'Close window' })

-- Fullscreen (close others)
vim.keymap.set('n', '<leader>wf', '<cmd>only<CR>', { desc = 'Fullscreen' })

-- =============================================================================
-- 📂 Explorer (<leader>e)
-- =============================================================================

-- Open file picker
vim.keymap.set('n', '<leader>ef', function()
  require('snacks').picker.files()
end, { desc = 'Open file picker' })

-- File tree view
vim.keymap.set('n', '<leader>et', function()
  require('snacks').picker.explorer()
end, { desc = 'File tree view' })

-- =============================================================================
-- ✨ Git (<leader>g)
-- =============================================================================

-- Lazygit
vim.keymap.set('n', '<leader>gg', function()
  require('snacks').lazygit()
end, { desc = 'Lazygit' })

-- =============================================================================
-- VIP Diagnostics and Code Actions (No prefix)
-- =============================================================================

-- equivalent (attempt Ruff fix for current line)
vim.keymap.set('n', '<leader>c.f', function()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_length = #vim.api.nvim_buf_get_lines(0, line-1, line, false)[1] or 1
  require('conform').format({
    async = true,
    lsp_format = 'fallback',
    range = {
      start = { line, 1 },
      ['end'] = { line, line_length + 1 },
    },
  })
end, { desc = 'Ruff fix @ cursor' })

-- Quick fix keybindings (VIP - VS Code style)
vim.keymap.set('n', '<C-.>', function()
  vim.lsp.buf.code_action()
end, { desc = 'Quick fix' })

-- Diagnostic navigation (VIP) - Keep run_and_remember for next error (repeatable)
vim.keymap.set('n', 'ge', function()
  run_and_remember(function() vim.diagnostic.goto_next() end)
end, { desc = 'Go to next error' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- Go to symbol/outline (VIP) - Remove run_and_remember from info display
vim.keymap.set('n', 'go', function()
  vim.lsp.buf.document_symbol()
end, { desc = 'Go to outline/symbols' })

-- Multi-cursor simulation (VIP - Visual mode)
vim.keymap.set('v', '<leader>ca', '<cmd>s/\\%V\\(\\S\\+\\)/&/g<CR>', { desc = 'Cursor on all' })


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
-- =============================================================================
-- Code Category (<leader>c)
-- =============================================================================

-- Code Actions (ca) - One-time actions, no need for run_and_remember
vim.keymap.set('n', '<leader>caa', function()
  vim.lsp.buf.code_action()
end, { desc = 'Code actions' })

vim.keymap.set('n', '<leader>cam', function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.lsp.buf.code_action({
    context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() },
    range = { start = {row, col}, ['end'] = {row, col} }
  })
end, { desc = 'Context menu' })

vim.keymap.set('n', '<leader>carn', function()
  vim.lsp.buf.rename()
end, { desc = 'Rename symbol' })

-- Python (cp) - One-time refactoring actions
vim.keymap.set('n', '<leader>cpr', function()
  vim.lsp.buf.code_action({ context = { only = { 'refactor' } } })
end, { desc = 'Python refactor' })

vim.keymap.set('n', '<leader>cpi', function()
  vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } } })
end, { desc = 'Organize imports' })

-- cpd (docstring) and cpx (execute) are defined in autocmds.lua and learn.lua

-- Goto (cg) - Will be defined in lsp_config.lua
-- cgr (references), cgd (definition), cgi (implementation), cgD (declaration), cgt (type definition)

-- Diagnostics (c.) - Keep run_and_remember for navigation (next/prev), remove from actions
vim.keymap.set('n', '<leader>c.n', function()
  run_and_remember(function() vim.diagnostic.goto_next() end)
end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '<leader>c.p', function()
  run_and_remember(function() vim.diagnostic.goto_prev() end)
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', '<leader>c.]', function()
  run_and_remember(function() vim.diagnostic.goto_next() end)
end, { desc = 'Next diagnostic (alt)' })

vim.keymap.set('n', '<leader>c.[', function()
  run_and_remember(function() vim.diagnostic.goto_prev() end)
end, { desc = 'Previous diagnostic (alt)' })

vim.keymap.set('n', '<leader>c.d', function()
  vim.diagnostic.open_float()
end, { desc = 'Diagnostic details' })

vim.keymap.set('n', '<leader>c.e', function()
  vim.diagnostic.setqflist({ severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Error messages list' })

vim.keymap.set('n', '<leader>c.q', function()
  vim.diagnostic.setqflist()
end, { desc = 'Diagnostics quickfix' })

vim.keymap.set('n', '<leader>c.u', function()
  vim.diagnostic.hide()
end, { desc = 'Hide diagnostics' })

-- Symbols (cs) - Will be defined in lsp_config.lua
-- cssf (document symbols), cssw (workspace symbols), csof (open document), csow (open workspace)

-- Format (cf) - One-time action
vim.keymap.set('n', '<leader>cfb', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format buffer' })

vim.keymap.set('v', '<leader>cfs', function()
  require('conform').format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format selection' })

-- Debug (cd)
vim.keymap.set('n', '<leader>cdb', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: toggle breakpoint' })

-- =============================================================================
-- Markers Category (<leader>m)
-- =============================================================================

-- Basic marker operations - Remove run_and_remember from toggles/actions
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
end, { desc = 'Toggle marker' })

-- Keep run_and_remember for navigation (next/prev)
vim.keymap.set('n', '<leader>mn', function()
  run_and_remember(function()
    vim.cmd("normal! ]'")
  end)
end, { desc = 'Next marker' })

vim.keymap.set('n', '<leader>mp', function()
  run_and_remember(function()
    vim.cmd("normal! ['")
  end)
end, { desc = 'Previous marker' })

vim.keymap.set('n', '<leader>ma', function()
  -- Add new mark at cursor
  local marks = vim.split(vim.fn.execute('marks'), '\n')
  local used_marks = {}
  for _, line in ipairs(marks) do
    local mark = line:match('^%s*([a-z])')
    if mark then used_marks[mark] = true end
  end
  for i = string.byte('a'), string.byte('z') do
    local mark = string.char(i)
    if not used_marks[mark] then
      vim.cmd('mark ' .. mark)
      print('Mark added: ' .. mark)
      return
    end
  end
end, { desc = 'Add marker' })

vim.keymap.set('n', '<leader>ml', '<cmd>marks<CR>', { desc = 'List markers' })

vim.keymap.set('n', '<leader>mi', function()
  vim.cmd('marks')
end, { desc = 'Marker info' })

vim.keymap.set('n', '<leader>md', function()
  -- Delete mark at cursor line
  local mark = vim.fn.input('Delete mark: ')
  if mark ~= '' then
    vim.cmd('delmarks ' .. mark)
    print('Mark deleted: ' .. mark)
  end
end, { desc = 'Delete marker' })

vim.keymap.set('n', '<leader>me', function()
  -- Edit/jump to mark
  local mark = vim.fn.input('Jump to mark: ')
  if mark ~= '' then
    vim.cmd("normal! '" .. mark)
  end
end, { desc = 'Edit/jump marker' })

vim.keymap.set('n', '<leader>mv', '<cmd>marks<CR>', { desc = 'Marker viewer' })

-- Marker Groups (mg) - Placeholder commands
vim.keymap.set('n', '<leader>mgc', function()
  print('Create marker group - requires marker-groups.nvim')
end, { desc = 'Create group' })

vim.keymap.set('n', '<leader>mgs', function()
  print('Select marker group - requires marker-groups.nvim')
end, { desc = 'Select group' })

vim.keymap.set('n', '<leader>mgl', function()
  print('List marker groups - requires marker-groups.nvim')
end, { desc = 'List groups' })

vim.keymap.set('n', '<leader>mgr', function()
  print('Rename marker group - requires marker-groups.nvim')
end, { desc = 'Rename group' })

vim.keymap.set('n', '<leader>mgd', function()
  print('Delete marker group - requires marker-groups.nvim')
end, { desc = 'Delete group' })

vim.keymap.set('n', '<leader>mgi', function()
  print('Marker group info - requires marker-groups.nvim')
end, { desc = 'Group info' })

vim.keymap.set('n', '<leader>mgb', function()
  print('Create group from branch - requires marker-groups.nvim')
end, { desc = 'From branch' })

-- =============================================================================
-- Learning Category (<leader>l)
-- =============================================================================

-- Learning info commands - Info displays don't need run_and_remember
vim.keymap.set('n', '<leader>li', function()
  require('core.learn').inspect_under_cursor()
end, { desc = 'Inspect element' })

vim.keymap.set('n', '<leader>lb', function()
  require('core.learn').buffer_info()
end, { desc = 'Buffer info' })

vim.keymap.set('n', '<leader>lw', function()
  require('core.learn').window_info()
end, { desc = 'Window info' })

vim.keymap.set('n', '<leader>ll', function()
  require('core.learn').lsp_info()
end, { desc = 'LSP info' })

vim.keymap.set('n', '<leader>lp', function()
  require('core.learn').plugin_info()
end, { desc = 'Plugin info' })

vim.keymap.set('n', '<leader>lk', function()
  require('core.learn').dump_keymaps()
end, { desc = 'Dump keymaps' })

vim.keymap.set('n', '<leader>lh', function()
  require('core.learn').highlight_under_cursor()
end, { desc = 'Highlight info' })

vim.keymap.set('n', '<leader>lo', function()
  require('core.learn').option_info()
end, { desc = 'Option info' })

vim.keymap.set('n', '<leader>l?', function()
  require('snacks').dashboard()
end, { desc = 'Dashboard' })

vim.keymap.set('n', '<leader>lhr', function()
  require('core.learn').reload_config()
end, { desc = 'Reload config' })

-- File path info commands
vim.keymap.set('n', '<leader>lf', function()
  local full_path = vim.fn.expand('%:p')
  local relative_path = vim.fn.expand('%')
  local filename = vim.fn.expand('%:t')

  if full_path == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  local lines = {
    'File Information:',
    '  Filename: ' .. filename,
    '  Relative: ' .. relative_path,
    '  Full path: ' .. full_path,
    '  Directory: ' .. vim.fn.expand('%:p:h'),
    '  Extension: ' .. vim.fn.expand('%:e'),
    '  Size: ' .. vim.fn.getfsize(full_path) .. ' bytes'
  }

  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO)
  print(full_path)  -- Also print to command line for easy copying
end, { desc = 'File path info' })

vim.keymap.set('n', '<leader>lfc', function()
  local full_path = vim.fn.expand('%:p')
  if full_path == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', full_path)  -- Copy to system clipboard
  vim.fn.setreg('"', full_path)  -- Copy to default register
  vim.notify('Full path copied to clipboard: ' .. full_path, vim.log.levels.INFO)
end, { desc = 'Copy full path' })

vim.keymap.set('n', '<leader>lfr', function()
  local relative_path = vim.fn.expand('%')
  if relative_path == '' then
    vim.notify('No file in current buffer', vim.log.levels.WARN)
    return
  end

  vim.fn.setreg('+', relative_path)  -- Copy to system clipboard
  vim.fn.setreg('"', relative_path)  -- Copy to default register
  vim.notify('Relative path copied: ' .. relative_path, vim.log.levels.INFO)
end, { desc = 'Copy relative path' })

-- Execute (lx) - Execution commands don't need repeat either
vim.keymap.set('n', '<leader>lxl', function()
  require('core.learn').exec_lua_line()
end, { desc = 'Execute Lua line' })

vim.keymap.set('v', '<leader>lxl', function()
  require('core.learn').exec_visual_selection()
end, { desc = 'Execute Lua selection' })

vim.keymap.set('n', '<leader>lxp', function()
  require('core.learn').exec_python_line()
end, { desc = 'Execute Python line' })

vim.keymap.set('v', '<leader>lxp', function()
  require('core.learn').exec_python_selection()
end, { desc = 'Execute Python selection' })

-- =============================================================================
-- Sessions Category (<leader>q)
-- =============================================================================

vim.keymap.set('n', '<leader>qs', function()
  require('persistence').load()
end, { desc = 'Restore session' })

vim.keymap.set('n', '<leader>ql', function()
  require('persistence').load({ last = true })
end, { desc = 'Restore last session' })

vim.keymap.set('n', '<leader>qd', function()
  require('persistence').stop()
end, { desc = "Don't save session" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

return M
