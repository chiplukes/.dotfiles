-- lua/plugins/init.lua
-- Return a table of plugin specs for Lazy.nvim to consume. Large plugin
-- configurations have been moved to individual files in this directory.

local plugins = {}

-- Load built-in grouped plugin specs in this file
local base = {
  -- Load the debugging config from lua/debug/debug.lua (was recently modified)
  require 'debug.debug',

  -- NOTE: Kickstart example plugins are available in lua/kickstart/plugins/ but not loaded by default.
  -- Uncomment any of the following to enable them:
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns',
}

vim.list_extend(plugins, base)

-- Load per-file plugin specs in lua/plugins/*.lua
local plugin_files = vim.fn.globpath(vim.fn.stdpath('config') .. '/lua/plugins', '*.lua', false, true)
for _, f in ipairs(plugin_files) do
  local name = vim.fn.fnamemodify(f, ':t')
  if name ~= 'init.lua' then
    local modname = 'plugins.' .. vim.fn.fnamemodify(f, ':t:r')
    local ok, spec = pcall(require, modname)
    if ok and type(spec) == 'table' then
      if vim.tbl_islist(spec) then
        vim.list_extend(plugins, spec)
      else
        table.insert(plugins, spec)
      end
    else
      vim.notify('Failed to load plugin module: ' .. modname, vim.log.levels.WARN)
    end
  end
end

return plugins