-- lua/plugins/utilities.lua
-- Small utility plugins that don't need their own files
return {
  -- Detect tabstop and shiftwidth automatically
  'NMAC427/guess-indent.nvim',

  -- Firenvim (nvim in browser textboxes)
  {
    'glacambre/firenvim',
    build = ':call firenvim#install(0)',
    config = function()
      vim.g.firenvim_config = {
        localSettings = {
          ['.*'] = {
            takeover = 'never',
          },
        },
      }
    end,
  },

  -- Oil.nvim - file explorer
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  },

  -- Gitsigns - git related signs to the gutter
  {
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

  -- Todo-comments - highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false }
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
}