-- lua/plugins/persistence.lua
-- Session management that works seamlessly with Snacks dashboard
return {
  'folke/persistence.nvim',
  event = 'BufReadPre', -- Only load when reading a file (not on dashboard)
  opts = {
    dir = vim.fn.stdpath('state') .. '/sessions/', -- Session directory
    -- What to save in sessions
    options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
    -- Don't save session when these buffers are open
    pre_save = nil,
    -- Additional session save hooks
    save_empty = false, -- Don't save empty sessions
  },
  keys = {
    {
      '<leader>qd',
      function()
        require('persistence').stop()
      end,
      desc = "Don't Save Current Session",
    },
  },
}
