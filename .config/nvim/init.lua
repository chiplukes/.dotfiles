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
-- All editor options, keymaps, autocommands, and commands are now modularized
pcall(require, 'core.options')
pcall(require, 'core.util')
pcall(require, 'core.keymaps')
pcall(require, 'core.autocmds')
pcall(require, 'core.commands')
pcall(require, 'plugins')

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
require('lazy').setup('plugins')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
