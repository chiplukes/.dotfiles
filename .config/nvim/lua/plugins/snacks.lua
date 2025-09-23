-- lua/plugins/snacks.lua
-- Snacks.nvim - lightweight collection of pickers/features
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
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
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = function()
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
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
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
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
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
}