-- lua/plugins/flash.lua
-- Flash - EasyMotion-like movement plugin
return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  keys = {
    { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump (EasyMotion-style)' },
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
}