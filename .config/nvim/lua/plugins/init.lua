-- lua/plugins/init.lua
-- Return a table of plugin specs for Lazy.nvim to consume. You can split
-- plugin specs into individual files under lua/plugins/*.lua and require
-- them here when the list grows.

local plugins = {}

-- Load built-in grouped plugin specs in this file
local base = {
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
}

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
    end
  end
end

return plugins
