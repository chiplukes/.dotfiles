-- lua/plugins/init.lua
-- Return a table of plugin specs for Lazy.nvim to consume. You can split
-- plugin specs into individual files under lua/plugins/*.lua and require
-- them here when the list grows.

return {
  -- Example: keep snacks/snacks config here (moved from init.lua earlier)
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      explorer = { enabled = true },
      picker = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      quickfile = { enabled = true },
      words = { enabled = true },
      dashboard = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
    },
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
  },
  -- Add other plugin specs here or create separate files in lua/plugins/
}
