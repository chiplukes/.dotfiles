--[[
    Started with kickstart.nvim (https://github.com/nvim-lua/kickstart.nvim)

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:


  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- set python provider to the .venv inside the nvim config dir (cross-platform)
local config_path = vim.fn.stdpath('config')       -- ~/.config/nvim or %APPDATA%/nvim on Windows
local venv_base = config_path .. '/.venv'
local py_exe = venv_base .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')

if vim.loop.fs_stat(py_exe) then
  vim.g.python3_host_prog = py_exe
else
  -- optional: leave unset or try a fallback (uncomment to print a warning)
  -- vim.notify('python provider not found at: ' .. py_exe, vim.log.levels.WARN)
end

-- Load core modular config pieces
-- `core.options` and `core.keymaps` replace the monolithic sections for
-- editor options and global keymaps. `plugins` returns plugin specs for Lazy.nvim.
pcall(require, 'core.options')
pcall(require, 'core.util')
pcall(require, 'plugins')
pcall(require, 'core.keymaps')

-- [[ Setting options ]]
-- See `:help vim.o`
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true



-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
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

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- =============================================================================
-- Enhanced Autocommands for Development (Phase 2)
-- =============================================================================

-- Python-specific enhancements
vim.api.nvim_create_augroup('PythonEnhancements', { clear = true })

-- Auto-organize imports on save for Python
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'PythonEnhancements',
  pattern = '*.py',
  callback = function()
    -- Only organize imports if isort or ruff is available
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == 'pyright' or client.name == 'pylsp' then
        -- Try to organize imports via LSP code action
        vim.lsp.buf.code_action({
          context = { only = { 'source.organizeImports' } },
          apply = true,
        })
        break
      end
    end
  end,
})

-- Auto-add docstrings for Python functions (when cursor is on function line)
vim.api.nvim_create_autocmd('FileType', {
  group = 'PythonEnhancements',
  pattern = 'python',
  callback = function()
    -- Add keymap for docstring generation
    vim.keymap.set('n', '<leader>pd', function()
      local line = vim.api.nvim_get_current_line()
      local row = vim.api.nvim_win_get_cursor(0)[1]

      -- Check if current line contains a function definition
      if line:match('^%s*def%s+') then
        local indent = line:match('^(%s*)')
        local docstring = {
          indent .. '"""',
          indent .. 'TODO: Add function description',
          indent .. '"""',
          ''
        }
        vim.api.nvim_buf_set_lines(0, row, row, false, docstring)
        -- Move cursor to docstring content
        vim.api.nvim_win_set_cursor(0, { row + 2, #indent + 4 })
      end
    end, { desc = '[P]ython Add [D]ocstring', buffer = true })
  end,
})

-- Verilog/SystemVerilog enhancements
vim.api.nvim_create_augroup('VerilogEnhancements', { clear = true })

-- Auto-format Verilog on save (with size limit for performance)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'VerilogEnhancements',
  pattern = { '*.v', '*.sv', '*.vh', '*.svh' },
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    -- Only auto-format smaller files to avoid performance issues
    if line_count <= 500 then
      require('conform').format({
        async = false,
        timeout_ms = 3000,
        bufnr = 0
      })
    else
      vim.notify('File too large for auto-format. Use <leader>bf to format manually.', vim.log.levels.INFO)
    end
  end,
})

-- Enhanced Verilog module instantiation helper
vim.api.nvim_create_autocmd('FileType', {
  group = 'VerilogEnhancements',
  pattern = { 'verilog', 'systemverilog' },
  callback = function()
    -- Add keymap for port connection helper
    vim.keymap.set('n', '<leader>vp', function()
      local word = vim.fn.expand('<cword>')
      local template = {
        '.' .. word .. '(' .. word .. '),',
      }
      vim.api.nvim_put(template, 'l', true, true)
    end, { desc = '[V]erilog [P]ort Connection', buffer = true })

    -- Add keymap for wire declaration
    vim.keymap.set('n', '<leader>vw', function()
      local word = vim.fn.expand('<cword>')
      vim.ui.input({ prompt = 'Wire width (default 1): ' }, function(width)
        width = width or '1'
        local wire_decl = string.format('wire [%s-1:0] %s;', width, word)
        vim.api.nvim_put({wire_decl}, 'l', true, true)
      end)
    end, { desc = '[V]erilog [W]ire Declaration', buffer = true })
  end,
})

-- Enhanced LSP workspace management
vim.api.nvim_create_augroup('LSPWorkspace', { clear = true })

-- Auto-detect Python virtual environments
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'LSPWorkspace',
  pattern = '*.py',
  callback = function()
    local cwd = vim.fn.getcwd()
    local venv_paths = {
      cwd .. '/.venv',
      cwd .. '/venv',
      vim.fn.expand('~/.venv'),
    }

    for _, path in ipairs(venv_paths) do
      if vim.fn.isdirectory(path) == 1 then
        vim.env.VIRTUAL_ENV = path
        local python_path = path .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')
        if vim.fn.executable(python_path) == 1 then
          vim.g.python3_host_prog = python_path
          -- Notify user about detected virtual environment
          vim.notify('Detected virtual environment: ' .. path, vim.log.levels.INFO)
          break
        end
      end
    end
  end,
})

-- Auto-save enabled (format on save disabled to prevent auto-formatting)
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = vim.api.nvim_create_augroup('AutoSave', { clear = true }),
  pattern = { '*.py', '*.lua', '*.js', '*.ts', '*.json', '*.md' }, -- Extended file type support
  callback = function()
    -- Auto-save after 3 seconds of inactivity (increased from 2s for better performance)
    vim.defer_fn(function()
      if vim.bo.modified and vim.bo.buftype == '' then
        vim.cmd('silent write')
      end
    end, 3000)
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.

-- =============================================================================
-- Diagnostic Commands for Troubleshooting LSP Issues
-- =============================================================================

-- Command to check what LSP servers are running and their capabilities
vim.api.nvim_create_user_command('LspDebug', function()
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if #clients == 0 then
    print('No LSP clients attached to current buffer')
    return
  end

  print('=== ACTIVE LSP SERVERS ===')
  for _, client in ipairs(clients) do
    print('Server: ' .. client.name)
    if client.config and client.config.settings then
      print('  Settings configured: Yes')
      if client.name == 'pylsp' and client.config.settings.pylsp and client.config.settings.pylsp.plugins then
        print('  Pylsp plugins:')
        for plugin, config in pairs(client.config.settings.pylsp.plugins) do
          if type(config) == 'table' and config.enabled ~= nil then
            print('    ' .. plugin .. ': ' .. (config.enabled and 'ENABLED' or 'disabled'))
          end
        end
      end
    else
      print('  Settings configured: No')
    end
    print('  Root dir: ' .. (client.config.root_dir or 'unknown'))
    print('  Capabilities: diagnostics=' .. tostring(client.server_capabilities.diagnosticProvider ~= nil))
    print('')
  end
end, { desc = 'Debug LSP server configuration and status' })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
