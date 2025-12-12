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

--   -- Oil.nvim - file explorer
--   {
--     'stevearc/oil.nvim',
--     -- Configure Oil to show folders/hidden files and avoid taking over as the
--     -- default file explorer (so our Snacks VimEnter autocommand can control
--     -- which UI is shown when starting with a directory).
--     opts = {
--       -- don't force itself as the default file explorer
--       default_file_explorer = false,
--       -- show folders and hidden files in the view
--       view_options = { show_hidden = true },
--     },
--     dependencies = { { 'echasnovski/mini.icons', opts = {} } },
--     config = function(_, opts)
--       local ok, oil = pcall(require, 'oil')
--       if ok and type(oil.setup) == 'function' then
--         oil.setup(opts or {})
--       end
--     end,
--   },

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
    dependencies = {
        "nvim-lua/plenary.nvim", -- Required
        "folke/snacks.nvim", -- Optional: Snacks picker
    },
    config = function()
      require('marker-groups').setup({
      -- Persistence
      data_dir = vim.fn.stdpath("data") .. "/marker-groups",

      -- Logging
      debug = false,
      log_level = "info",

      -- Drawer viewer
      drawer_config = {
        width = 60,       -- 30..120
        side = "right",   -- "left" | "right"
        border = "rounded",
        title_pos = "center",
      },

      -- Context shown around markers in viewer/preview
      context_lines = 2,

      -- Virtual text display
       max_annotation_display = 50,

       -- Highlight groups used for rendering (override names to integrate with colorschemes)
       highlight_groups = {
         marker = "MarkerGroupsMarker",
         annotation = "MarkerGroupsAnnotation",
         context = "MarkerGroupsContext",
         multiline_start = "MarkerGroupsMultilineStart",
         multiline_end = "MarkerGroupsMultilineEnd",
       },

      -- Keybinding configuration (declarative)
      -- Disable plugin defaults; we define custom keymaps in keymaps.lua
      keymaps = {
        enabled = false,
      },
      -- Picker backend (default: 'vim')
      -- Accepted values: 'vim' | 'snacks' | 'fzf-lua' | 'mini.pick' | 'telescope'
      -- Invalid values fall back to 'vim'.
      picker = 'snacks',
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