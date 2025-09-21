--[[
====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
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

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
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
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically

  -- Firenvim (nvim in browser textboxes)
  {
    'glacambre/firenvim',
    build = ':call firenvim#install(0)',
    config = function()
      vim.g.firenvim_config = {
        -- config values, like in my case:
        localSettings = {
          ['.*'] = {
            takeover = 'never',
          },
        },
      }
    end,
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    -- @type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    'stevearc/oil.nvim',
    -- @module 'oil'
    -- @type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  -- =============================================================================
  -- Python Debugger Configuration (DAP - Debug Adapter Protocol)
  -- =============================================================================
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Python debugger
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with reasonable debug configurations
        automatic_setup = true,
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please read mason-nvim-dap README for more information
        ensure_installed = {
          'debugpy', -- Python
        },
      }

      -- Basic debugging keymaps, feel free to change to your liking!
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Python debugger setup with virtual environment detection
      local function get_python_path()
        -- Check for VIRTUAL_ENV environment variable
        local venv_path = vim.fn.getenv('VIRTUAL_ENV')
        if venv_path and venv_path ~= vim.NIL then
          return venv_path .. (vim.fn.has('win32') == 1 and '\\Scripts\\python.exe' or '/bin/python')
        end

        -- Check for local .venv directory
        local cwd = vim.fn.getcwd()
        local venv_dirs = { '.venv', 'venv', '.env', 'env' }

        for _, venv_dir in ipairs(venv_dirs) do
          local local_venv = cwd .. '/' .. venv_dir
          if vim.fn.isdirectory(local_venv) == 1 then
            return local_venv .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')
          end
        end

        -- Check for conda environment
        local conda_env = vim.fn.getenv('CONDA_DEFAULT_ENV')
        if conda_env and conda_env ~= vim.NIL and conda_env ~= 'base' then
          local conda_path = vim.fn.getenv('CONDA_PREFIX')
          if conda_path and conda_path ~= vim.NIL then
            return conda_path .. (vim.fn.has('win32') == 1 and '\\python.exe' or '/bin/python')
          end
        end

        -- Check for Poetry virtual environment
        local poetry_venv = vim.fn.system('poetry env info --path 2>/dev/null'):gsub('\n', '')
        if vim.v.shell_error == 0 and poetry_venv and poetry_venv ~= '' then
          return poetry_venv .. (vim.fn.has('win32') == 1 and '\\Scripts\\python.exe' or '/bin/python')
        end

        -- Fallback to system python
        return 'python'
      end

      local python_path = get_python_path()

      -- Install debugpy on-demand when debugging starts
      local function ensure_debugpy_on_debug(python_executable, callback)
        if python_executable == 'python' then
          -- Using system Python, assume debugpy is available or user will install manually
          vim.notify('Using system Python - ensure debugpy is installed globally', vim.log.levels.INFO)
          if callback then callback() end
          return
        end

        -- Check if debugpy is installed
        local check_cmd = python_executable .. ' -c "import debugpy; print(debugpy.__version__)"'
        local result = vim.fn.system(check_cmd)

        if vim.v.shell_error ~= 0 then
          -- debugpy not found - install it
          vim.notify('🐍 debugpy not found - installing for debugging...', vim.log.levels.WARN)
          print('=== DEBUGPY INSTALLATION ===')
          print('debugpy required for debugging - installing...')

          -- Detect if this is a uv environment by checking if pip module is available
          local pip_check_cmd = python_executable .. ' -c "import pip"'
          local pip_available = vim.fn.system(pip_check_cmd)
          local has_pip = vim.v.shell_error == 0

          local install_cmd
          if has_pip then
            -- Standard virtual environment with pip
            install_cmd = python_executable .. ' -m pip install debugpy'
            print('Running: ' .. install_cmd)
            print('(Using python -m pip)')
          else
            -- Likely a uv environment - try using uv directly
            install_cmd = 'uv add --dev debugpy'
            print('Running: ' .. install_cmd)
            print('(Detected uv environment - using uv add)')
          end

          vim.fn.jobstart(install_cmd, {
            on_stdout = function(_, data)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line and line ~= '' then
                    print('install: ' .. line)
                  end
                end
              end
            end,
            on_stderr = function(_, data)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line and line ~= '' then
                    print('install error: ' .. line)
                  end
                end
              end
            end,
            on_exit = function(_, exit_code)
              if exit_code == 0 then
                print('=== DEBUGPY INSTALLATION SUCCESS ===')
                print('✅ debugpy successfully installed!')
                vim.notify('✅ debugpy installed - starting debugger...', vim.log.levels.INFO)
                if callback then callback() end
              else
                print('=== DEBUGPY INSTALLATION FAILED ===')
                print('❌ Failed to install debugpy (exit code: ' .. exit_code .. ')')
                if has_pip then
                  print('💡 Manual installation: python -m pip install debugpy')
                  vim.notify('❌ debugpy installation failed! Install manually: python -m pip install debugpy', vim.log.levels.ERROR)
                else
                  print('💡 Manual installation: uv add --dev debugpy')
                  vim.notify('❌ debugpy installation failed! Install manually: uv add --dev debugpy', vim.log.levels.ERROR)
                end
              end
            end,
          })
        else
          -- debugpy is already installed
          local version = result:gsub('\n', ''):gsub('\r', '')
          vim.notify('✅ debugpy found (v' .. version .. ') - starting debugger...', vim.log.levels.INFO)
          if callback then callback() end
        end
      end

      require('dap-python').setup(python_path)

      -- Enhanced DAP configuration with on-demand debugpy installation
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = python_path,
          console = 'integratedTerminal',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch with arguments',
          program = '${file}',
          pythonPath = python_path,
          console = 'integratedTerminal',
          cwd = '${workspaceFolder}',
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' ')
          end,
        },
      }

      -- Override the DAP continue function to ensure debugpy before starting
      local original_continue = dap.continue
      dap.continue = function()
        ensure_debugpy_on_debug(python_path, function()
          original_continue()
        end)
      end

      -- Add DAP event listeners for better error reporting
      dap.listeners.before.event_terminated['error_handler'] = function(session, body)
        if body and body.exitCode and body.exitCode ~= 0 then
          vim.notify(
            string.format('Python debugger exited with code: %d. Check :DapShowLog for details.', body.exitCode),
            vim.log.levels.ERROR
          )
        end
      end

      dap.listeners.before.event_exited['error_handler'] = function(session, body)
        if body and body.exitCode and body.exitCode ~= 0 then
          vim.notify(
            string.format('Python process exited with error code: %d', body.exitCode),
            vim.log.levels.ERROR
          )
        end
      end

      -- Add helpful keybindings for debugging issues
      vim.keymap.set('n', '<leader>dl', function()
        dap.set_log_level('TRACE')
        vim.notify('DAP log level set to TRACE. Use :DapShowLog to view logs.', vim.log.levels.INFO)
      end, { desc = 'Debug: Enable verbose logging' })

      vim.keymap.set('n', '<leader>ds', ':DapShowLog<CR>', { desc = 'Debug: Show DAP log' })

      -- Add command to manually install debugpy
      vim.api.nvim_create_user_command('DebugpyInstall', function()
        ensure_debugpy_on_debug(python_path, function()
          vim.notify('✅ debugpy installation check complete!', vim.log.levels.INFO)
        end)
      end, { desc = 'Install debugpy in current virtual environment' })

      -- Add some helpful debug messages
      vim.notify('Python debugger configured with: ' .. python_path, vim.log.levels.INFO)
      vim.notify('debugpy will be auto-installed when you start debugging', vim.log.levels.INFO)
      vim.notify('Use :DebugpyInstall to install debugpy manually', vim.log.levels.INFO)
    end,
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.o.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Snacks: lightweight collection of pickers/features to replace Telescope
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      explorer = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      words = { enabled = true },
      dashboard = {
          enabled = true,
          pane_gap = 20,
          preset = {
          -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
          pick = nil,
          -- Used by the `keys` section to show keymaps.
          -- Set your custom keymaps here.
          -- When using a function, the `items` argument are the default keymaps.
          keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = function()
                  -- Create a new buffer without entering insert mode. Some Snacks
                  -- actions use `startinsert` which can leave the UI in insert
                  -- mode; this avoids that and proactively clears any pending
                  -- insert-state by sending a safe <Esc> after creating the buffer.
                  vim.cmd('enew')
                  -- Ensure we're in normal mode (in case other callbacks try to re-enter insert)
                  if vim.api.nvim_get_mode().mode ~= 'n' then
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
                  end
                end },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
              },
              { icon = " ", key = "s", desc = "Restore Session", section = "session" },
              { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          -- Used by the `header` section
          header = [[
      ´.-::::::-.´
      .:-::::::::::::::-:.
      ´_:::    ::    :::_´
      .:( ^   :: ^   ):.
      ´:::   (..)   :::.
      ´:::::::UU:::::::´
      .::::::::::::::::.
      O::::::::::::::::O
      -::::::::::::::::-
      ´::::::::::::::::´
          .::::::::::::::.
          oO:::::::Oo
      ]],
          },
          sections = {
          { section = "header" },
        --   {
        --       pane = 2,
        --       section = "terminal",
        --       -- See:
        --       -- [Derek Taylor / Shell Color Scripts · GitLab](https://gitlab.com/dwt1/shell-color-scripts)
        --       --cmd = "colorscript -e square",
        --       cmd = "dir",
        --       height = 5,
        --       padding = 0,
        --   },
        --   {
        --       pane = 2,
        --       section = "terminal",
        --       --cmd = "colorscript -e crunch",
        --       cmd = "dir",
        --       height = 5,
        --       padding = 4,
        --   },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
              pane = 2,
              icon = " ",
              title = "Git Status",
              section = "terminal",
              enabled = function()
              return Snacks.git.get_root() ~= nil
              end,
              cmd = "git status --short --branch --renames",
              height = 5,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
          },
          { section = "startup" },
          },
        },
      indent = { enabled = true },
      input = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
    },
    dependencies = {
      -- optional icons (keeps parity with previous config)
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    -- Map the keybindings that previously pointed to Telescope to Snacks equivalents
    keys = {
      { '<leader>sh', function() require('snacks').picker.help() end, desc = '[S]earch [H]elp' },
      { '<leader>sk', function() require('snacks').picker.keymaps() end, desc = '[S]earch [K]eymaps' },
      { '<leader>sf', function() require('snacks').picker.files() end, desc = '[S]earch [F]iles' },
      { '<leader>ss', function() require('snacks').picker.smart() end, desc = '[S]earch [S]mart' },
      { '<leader>sw', function() require('snacks').picker.grep_word() end, desc = '[S]earch current [W]ord' },
      { '<leader>sg', function() require('snacks').picker.grep() end, desc = '[S]earch by [G]rep' },
      { '<leader>sd', function() require('snacks').picker.diagnostics() end, desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', function() require('snacks').picker.resume() end, desc = '[S]earch [R]esume' },
      { '<leader>s.', function() require('snacks').picker.recent() end, desc = '[S]earch Recent Files' },
      { '<leader><leader>', function() require('snacks').picker.buffers() end, desc = '[ ] Find existing buffers' },
      { '<leader>/', function() require('snacks').picker.lines() end, desc = '[/] Fuzzily search in current buffer' },
      { '<leader>s/', function() require('snacks').picker.search_history() end, desc = '[S]earch [/] in Open Files' },
      { '<leader>sn', function() require('snacks').picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = '[S]earch [N]eovim files' },
    },
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- Find references for the word under your cursor.
          map('grr', function() require('snacks').picker.lsp_references() end, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gri', function() require('snacks').picker.lsp_implementations() end, '[G]oto [I]mplementation')

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('grd', function() require('snacks').picker.lsp_definitions() end, '[G]oto [D]efinition')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('gO', function() require('snacks').picker.lsp_symbols() end, 'Open Document Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('gW', function() require('snacks').picker.lsp_symbols({ workspace = true }) end, 'Open Workspace Symbols')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('grt', function() require('snacks').picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- =============================================================================
          -- Enhanced LSP Keybindings (Phase 2)
          -- =============================================================================

          -- Advanced diagnostic navigation
          map('gdn', function()
            vim.diagnostic.goto_next({ float = true })
          end, '[G]oto [D]iagnostic [N]ext')

          map('gdp', function()
            vim.diagnostic.goto_prev({ float = true })
          end, '[G]oto [D]iagnostic [P]revious')

          -- Show diagnostic in floating window
          map('gdd', function()
            vim.diagnostic.open_float(nil, { focusable = true, border = 'rounded' })
          end, '[G]oto [D]iagnostic [D]etails')

          -- Workspace management
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- Enhanced code actions with context
          map('<leader>ca', function()
            vim.lsp.buf.code_action({
              context = {
                only = { 'quickfix', 'refactor', 'source' },
                diagnostics = vim.diagnostic.get(0)
              }
            })
          end, '[C]ode [A]ctions (Enhanced)')

          -- Organize imports (if supported)
          if client and client_supports_method(client, 'textDocument/codeAction', event.buf) then
            map('<leader>oi', function()
              vim.lsp.buf.code_action({
                context = { only = { 'source.organizeImports' } },
                apply = true
              })
            end, '[O]rganize [I]mports')
          end

          -- Format current buffer or selection
          map('<leader>bf', function()
            vim.lsp.buf.format({
              async = true,
              filter = function(format_client)
                -- Prefer specific formatters over LSP formatting
                local preferred_formatters = {
                  python = { 'black', 'autopep8' },
                  verilog = { 'verible' },
                  systemverilog = { 'verible' },
                }
                local ft = vim.bo.filetype
                if preferred_formatters[ft] then
                  return vim.tbl_contains(preferred_formatters[ft], format_client.name)
                end
                return true
              end
            })
          end, '[B]uffer [F]ormat')

          -- Enhanced signature help with better positioning
          map('<C-k>', function()
            vim.lsp.buf.signature_help()
          end, 'Signature Help', 'i')

          -- Hover with enhanced formatting
          map('K', function()
            -- Try LSP hover first, fallback to vim's default K
            local params = vim.lsp.util.make_position_params()
            vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result)
              if err or not result or not result.contents then
                -- Fallback to default K behavior
                local word = vim.fn.expand('<cword>')
                vim.cmd('help ' .. word)
              else
                vim.lsp.util.open_floating_preview(result.contents, 'markdown', {
                  border = 'rounded',
                  max_width = 80,
                  max_height = 20,
                  focusable = true,
                })
              end
            end)
          end, 'Hover Documentation')

          -- Enhanced symbol search
          map('<leader>ss', function()
            require('snacks').picker.lsp_symbols()
          end, '[S]earch Document [S]ymbols')

          map('<leader>sS', function()
            require('snacks').picker.lsp_symbols({ workspace = true })
          end, '[S]earch Workspace [S]ymbols')

          -- Language-specific enhancements
          local filetype = vim.bo[event.buf].filetype

          -- Python-specific keybindings
          if filetype == 'python' then
            map('<leader>pi', function()
              vim.lsp.buf.code_action({
                context = { only = { 'source.addMissingImports' } },
                apply = true
              })
            end, '[P]ython Add Missing [I]mports')

            map('<leader>pr', function()
              vim.lsp.buf.code_action({
                context = { only = { 'refactor.extract' } }
              })
            end, '[P]ython [R]efactor Extract')
          end

          -- Verilog-specific keybindings
          if filetype == 'verilog' or filetype == 'systemverilog' then
            map('<leader>vm', function()
              -- Custom module instantiation helper
              local word = vim.fn.expand('<cword>')
              vim.ui.input({ prompt = 'Instance name: ' }, function(instance_name)
                if instance_name then
                  local template = string.format('%s %s_inst (\n    // TODO: Connect ports\n);', word, instance_name)
                  vim.api.nvim_put({template}, 'l', true, true)
                end
              end)
            end, '[V]erilog [M]odule Instantiation')
          end

          -- Inlay hints toggle (enhanced)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              local current_setting = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              vim.lsp.inlay_hint.enable(not current_setting, { bufnr = event.buf })
              vim.notify(string.format('Inlay hints %s', current_setting and 'disabled' or 'enabled'))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- =============================================================================
      -- Enhanced Diagnostic Configuration (Phase 2)
      -- =============================================================================
      vim.diagnostic.config {
        -- Sort by severity (errors first, then warnings, etc.)
        severity_sort = true,

        -- Enhanced floating window configuration
        float = {
          border = 'rounded',
          source = 'if_many',
          header = '',
          prefix = '',
          -- Add padding and better formatting
          focusable = true,
          style = 'minimal',
          max_width = 80,
          max_height = 20,
        },

        -- Enhanced underline configuration
        underline = {
          severity = { min = vim.diagnostic.severity.HINT } -- Underline all diagnostics
        },

        -- Enhanced signs configuration
        signs = {
          text = vim.g.have_nerd_font and {
            [vim.diagnostic.severity.ERROR] = '󰅚',
            [vim.diagnostic.severity.WARN] = '󰀪',
            [vim.diagnostic.severity.INFO] = '󰋽',
            [vim.diagnostic.severity.HINT] = '󰌶',
          } or {
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN] = 'W',
            [vim.diagnostic.severity.INFO] = 'I',
            [vim.diagnostic.severity.HINT] = 'H',
          },
          -- Add line highlight for errors
          linehl = {},
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
          },
        },

        -- Enhanced virtual text configuration
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          prefix = '●',
          -- Only show virtual text for errors and warnings to reduce noise
          severity = { min = vim.diagnostic.severity.WARN },
          format = function(diagnostic)
            -- Add severity prefix and limit message length
            local max_len = 50
            local message = diagnostic.message
            if #message > max_len then
              message = message:sub(1, max_len - 3) .. '...'
            end

            local severity_icons = {
              [vim.diagnostic.severity.ERROR] = '󰅚',
              [vim.diagnostic.severity.WARN] = '󰀪',
              [vim.diagnostic.severity.INFO] = '󰋽',
              [vim.diagnostic.severity.HINT] = '󰌶',
            }

            local icon = severity_icons[diagnostic.severity] or '●'
            return string.format('%s %s', icon, message)
          end,
        },

        -- Enhanced update behavior
        update_in_insert = false, -- Don't show diagnostics while typing
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        -- =============================================================================
        -- Python LSP Configuration (hendrikmi approach - Ruff-focused)
        -- =============================================================================
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                -- Disable ALL linting/formatting plugins to avoid conflicts with Ruff
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                mccabe = { enabled = false },
                pylsp_mypy = { enabled = false },
                pylsp_black = { enabled = false },
                pylsp_isort = { enabled = false },
                -- Additional plugins that might cause issues
                pydocstyle = { enabled = false },
                pylint = { enabled = false },
                flake8 = { enabled = false },
                rope_autoimport = { enabled = false },
                rope_completion = { enabled = false },
                -- Keep only basic language server functionality
                jedi_completion = { enabled = true },
                jedi_hover = { enabled = true },
                jedi_references = { enabled = true },
                jedi_signature_help = { enabled = true },
                jedi_symbols = { enabled = true },
              },
            },
          },
          -- Keep virtual environment auto-detection as requested
          on_init = function(client, initialize_result)
            -- Detect virtual environment
            local venv_path = vim.fn.getenv('VIRTUAL_ENV')
            if venv_path then
              client.config.settings.python.pythonPath = venv_path .. '/bin/python'
            else
              -- Try to find local .venv
              local local_venv = vim.fn.getcwd() .. '/.venv'
              if vim.fn.isdirectory(local_venv) == 1 then
                client.config.settings.python.pythonPath = local_venv .. '/bin/python'
              end
            end
            client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
          end,
        },

        -- Ruff LSP for fast Python linting and formatting
        ruff = {
          init_options = {
            settings = {
              -- Configure Ruff to be the primary Python tool
              args = { '--extend-select', 'I' }, -- Enable import sorting
            },
          },
        },

        -- =============================================================================
        -- C/C++ LSP Configuration (Phase 5: C/C++ Support)
        -- =============================================================================
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern(
              '.clangd',
              '.clang-tidy',
              '.clang-format',
              'compile_commands.json',
              'compile_flags.txt',
              'configure.ac',
              '.git'
            )(fname) or vim.fn.getcwd()
          end,
        },

        -- =============================================================================
        -- Verilog/SystemVerilog LSP Configuration
        -- =============================================================================
        -- Note: svls (SystemVerilog Language Server) is not available in Mason
        -- and would need to be manually installed. Using Verible instead.

        -- Verible language server (available in Mason)
        verible = {
          cmd = { 'verible-verilog-ls', '--rules_config_search' },
          filetypes = { 'verilog', 'systemverilog' },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern(
              '.rules.verible_lint',
              'verible.filelist',
              '.git'
            )(fname) or vim.fn.getcwd()
          end,
        },

        -- =============================================================================
        -- Lua LSP (Enhanced)
        -- =============================================================================
        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- Enhanced Lua diagnostics
              diagnostics = {
                -- Recognize vim global
                globals = { 'vim', 'require' },
                -- Disable noisy warnings for Neovim config
                disable = { 'missing-fields', 'incomplete-signature-doc' },
              },
              -- Workspace configuration for Neovim development
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false, -- Disable third-party checking
              },
              -- Enhanced telemetry settings
              telemetry = { enable = false },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        -- =============================================================================
        -- Enhanced Tools for Phase 2 Development
        -- =============================================================================

        -- Lua tools
        'stylua', -- Lua formatter

        -- Python tools (Ruff-focused approach like hendrikmi)
        'ruff',          -- Primary Python linter and formatter
        'ruff-lsp',      -- Ruff LSP server
        'debugpy',       -- Python debugger for nvim-dap
        -- Note: Most Python tools removed to avoid conflicts with Ruff

        -- C/C++ tools (Phase 5: C/C++ Support)
        'clangd',        -- C/C++ LSP server for code navigation and linting (includes clang-tidy)
        'clang-format',  -- C/C++ code formatter
        -- Note: cppcheck not available in Mason, but clangd provides excellent linting via clang-tidy

        -- Verilog/SystemVerilog tools
        'verible',       -- SystemVerilog formatter and linter (includes verible-verilog-ls)

        -- General development tools
        'prettier',      -- Multi-language formatter
        'fixjson',       -- JSON formatter
        'yamllint',      -- YAML linter
        'shellcheck',    -- Shell script linter
        'shfmt',         -- Shell script formatter

        -- Additional useful tools
        'codespell',     -- Spell checker for code
        'gitlint',       -- Git commit message linter
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      -- =============================================================================
      -- Enhanced Conform Configuration (Phase 2)
      -- =============================================================================
      notify_on_error = true, -- Show notifications for formatting errors

      -- Format on save DISABLED (use <leader>f for manual formatting)
      -- This prevents auto-formatting while auto-save is enabled
      format_on_save = nil,

      -- Alternative: Uncomment below to re-enable format on save for specific files only
      --[[
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype

        -- Disable auto-format for most file types (manual control preferred)
        local disable_filetypes = {
          python = true,     -- Use manual formatting with <leader>f
          lua = true,        -- Use manual formatting with <leader>f
          c = true,
          cpp = true,
          javascript = true,
          typescript = true,
          -- Don't auto-format large Verilog files (can be slow)
          verilog = vim.fn.line('$') > 1000,
          systemverilog = vim.fn.line('$') > 1000,
        }

        if disable_filetypes[ft] then
          return nil
        end

        -- File type specific timeouts
        local timeout_by_ft = {
          python = 2000,      -- Python formatting can be slower
          verilog = 3000,     -- Verilog formatting can be very slow
          systemverilog = 3000,
          default = 1000,
        }

        return {
          timeout_ms = timeout_by_ft[ft] or timeout_by_ft.default,
          lsp_format = 'fallback',
          async = false, -- Synchronous for format on save
        }
      end,
      --]]

      -- Comprehensive formatters by file type
      formatters_by_ft = {
        -- =============================================================================
        -- Lua
        -- =============================================================================
        lua = { 'stylua' },

        -- =============================================================================
        -- Python (Ruff-focused approach like hendrikmi)
        -- =============================================================================
        python = { 'ruff_format', 'ruff_organize_imports' },

        -- =============================================================================
        -- C/C++ (Phase 5: C/C++ Support)
        -- =============================================================================
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        cxx = { 'clang_format' },
        cc = { 'clang_format' },
        h = { 'clang_format' },
        hpp = { 'clang_format' },
        hxx = { 'clang_format' },

        -- =============================================================================
        -- Verilog/SystemVerilog
        -- =============================================================================
        verilog = { 'verible_verilog_format' },
        systemverilog = { 'verible_verilog_format' },

        -- =============================================================================
        -- Web and Configuration Files
        -- =============================================================================
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'fixjson', 'prettier', stop_after_first = true },
        yaml = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        markdown = { 'prettier' },

        -- =============================================================================
        -- Shell and Other
        -- =============================================================================
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
      },

      -- =============================================================================
      -- Custom Formatter Configurations
      -- =============================================================================
      formatters = {
        -- Enhanced Black configuration
        black = {
          prepend_args = { '--line-length', '88', '--fast' },
        },

        -- Enhanced isort configuration
        isort = {
          prepend_args = { '--profile', 'black', '--line-length', '88' },
        },

        -- Ruff formatter configuration
        ruff_format = {
          command = 'ruff',
          args = { 'format', '--stdin-filename', '$FILENAME', '-' },
          stdin = true,
        },

        ruff_organize_imports = {
          command = 'ruff',
          args = { 'check', '--select', 'I', '--fix', '--stdin-filename', '$FILENAME', '-' },
          stdin = true,
        },

        -- C/C++ clang-format configuration (Phase 5: C/C++ Support)
        clang_format = {
          command = 'clang-format',
          args = {
            '--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}',
            '--assume-filename=$FILENAME'
          },
          stdin = true,
        },

        -- Verible Verilog formatter configuration
        verible_verilog_format = {
          command = 'verible-verilog-format',
          args = {
            '--assignment_statement_alignment=preserve',
            '--case_items_alignment=infer',
            '--class_member_variables_alignment=infer',
            '--formal_parameters_alignment=preserve',
            '--named_parameter_alignment=flush-left',
            '--named_port_alignment=flush-left',
            '--port_declarations_alignment=preserve',
            '$FILENAME',
          },
          stdin = false,
        },

        -- Enhanced stylua configuration
        stylua = {
          prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2' },
        },

        -- Shell formatter configuration
        shfmt = {
          prepend_args = { '-i', '2', '-ci' }, -- 2 spaces, switch case indent
        },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        -- Custom keymap to exactly match your VS Code keybindings
        preset = 'none', -- Use custom mappings
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<C-u>'] = { 'hide', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' }, -- Alternative hide

        -- Keep useful defaults
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

  { -- GitHub Copilot (Phase 5: AI-powered code completion)
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      -- Disable default keybindings to set custom ones that match VS Code
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Custom keybindings to match VS Code Copilot extension
      vim.keymap.set('i', '<Tab>', function()
        if vim.fn['copilot#Accept']('') ~= '' then
          return vim.fn['copilot#Accept']('')
        else
          return '<Tab>'
        end
      end, { expr = true, replace_keycodes = false, desc = 'Accept Copilot suggestion or Tab' })

      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)', { desc = 'Next Copilot suggestion' })
      vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)', { desc = 'Previous Copilot suggestion' })
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)', { desc = 'Dismiss Copilot suggestion' })

      -- Word-level acceptance (like VS Code Ctrl+Right Arrow)
      vim.keymap.set('i', '<C-Right>', '<Plug>(copilot-accept-word)', { desc = 'Accept Copilot word' })

      -- Show Copilot panel (like VS Code Ctrl+Enter)
      vim.keymap.set('i', '<C-CR>', '<Plug>(copilot-suggest)', { desc = 'Show Copilot suggestions panel' })
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },



  -- =============================================================================
  -- Custom Plugins for Enhanced Functionality
  -- =============================================================================

  -- Flash for EasyMotion-like movement (modern and fast)
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = '[S] Flash jump (EasyMotion-style)' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = '[S] Flash treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Flash treesitter search' },
    },
    opts = {
      -- Flash configuration to match VSCode EasyMotion behavior
      labels = 'asdfghjklqwertyuiopzxcvbnm',
      search = {
        -- Search settings for better UX
        multi_window = true,
        forward = true,
        wrap = true,
        incremental = false,
      },
      jump = {
        -- Jump behavior
        jumplist = true,
        pos = 'start',
        history = false,
        register = false,
      },
      label = {
        -- Label appearance
        uppercase = false,
        exclude = '',
        current = true,
        after = true,
        before = false,
        style = 'overlay',
      },
      highlight = {
        -- Colors and highlighting
        backdrop = true,
        matches = true,
        priority = 5000,
      },
      modes = {
        -- Configure different flash modes
        search = {
          enabled = true,
          highlight = { backdrop = false },
          jump = { history = true, register = true, nohlsearch = true },
        },
        char = {
          enabled = true,
          config = function(opts)
            -- Autohide flash when in operator-pending mode
            opts.autohide = opts.autohide or (vim.fn.mode(true):find('no') and vim.v.operator == 'y')
          end,
          -- Hide after jump when in operator-pending mode
          autohide = true,
          jump_labels = true,
          multi_line = true,
        },
      },
    },
  },

  -- Marker Groups for enhanced bookmarking (similar to VSCode bookmarks)
  {
    'jameswolensky/marker-groups.nvim',
    config = function()
      require('marker-groups').setup({
        -- Configuration will be added as we enhance bookmarks
      })
    end,
  },

  -- Align plugin for text alignment (matching VSCode align-by-regex)
  {
    'Vonr/align.nvim',
    config = function()
      -- Set up align keybinding to match VSCode 'ga' in visual mode
      vim.keymap.set('v', 'ga', function()
        require('align').align_to_char({
          length = 1,
          preview = true,
        })
      end, { desc = '[G]o [A]lign by character' })

      -- Additional alignment options
      vim.keymap.set('v', 'gA', function()
        require('align').align_to_string({
          preview = true,
          regex = true,
        })
      end, { desc = '[G]o [A]lign by regex/string' })
    end,
  },

  -- LuaSnip for advanced snippets (with custom Python/Verilog snippets)
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      local luasnip = require('luasnip')

      -- Load friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      -- Load our custom snippets (we'll create these files)
      require('luasnip.loaders.from_lua').load({ paths = vim.fn.stdpath('config') .. '/lua/snippets' })

      -- Snippet expansion and navigation keybindings
      vim.keymap.set({'i', 's'}, '<Tab>', function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          return '<Tab>'
        end
      end, {expr = true, silent = true})

      vim.keymap.set({'i', 's'}, '<S-Tab>', function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          return '<S-Tab>'
        end
      end, {expr = true, silent = true})

      -- Choice selection
      vim.keymap.set('i', '<C-e>', function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end)
    end,
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      -- =============================================================================
      -- Enhanced Treesitter Languages (Phase 2)
      -- =============================================================================
      ensure_installed = {
        -- Base languages
        'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',

        -- Python and related
        'python', 'toml', 'yaml', 'json', 'requirements',

        -- Verilog/SystemVerilog (if available)
        'verilog',

        -- Web development
        'javascript', 'typescript', 'css', 'scss',

        -- Configuration and data formats
        'dockerfile', 'gitignore', 'gitcommit', 'ini',

        -- Shell and scripting
        'regex', 'ssh_config',

        -- Additional useful languages
        'make', 'cmake', 'ninja',
      },

      -- Autoinstall languages that are not installed
      auto_install = true,

      -- Enhanced highlighting configuration
      highlight = {
        enable = true,
        -- Disable highlighting for very large files (performance)
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,

        -- Some languages depend on vim's regex highlighting system for indent rules
        additional_vim_regex_highlighting = { 'ruby', 'verilog' },
      },

      -- Enhanced indentation
      indent = {
        enable = true,
        disable = { 'ruby', 'python' }, -- Python indentation can be tricky with Treesitter
      },

      -- Enhanced incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = '<C-s>',
          node_decremental = '<M-space>',
        },
      },

      -- Enhanced text objects (if nvim-treesitter-textobjects is installed)
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            -- Python-specific text objects
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',

            -- General text objects
            ['ab'] = '@block.outer',
            ['ib'] = '@block.inner',
            ['al'] = '@loop.outer',
            ['il'] = '@loop.inner',
            ['ad'] = '@conditional.outer',
            ['id'] = '@conditional.inner',
          },
        },

        -- Enhanced movement
        move = {
          enable = true,
          set_jumps = true, -- Add to jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },

        -- Swap parameters/arguments
        swap = {
          enable = true,
          swap_next = {
            ['<leader>sn'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>sp'] = '@parameter.inner',
          },
        },
      },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

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
