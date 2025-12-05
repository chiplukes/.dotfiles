-- lua/plugins/snacks.lua
-- Snacks.nvim - lightweight collection of pickers/features
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      enabled = true,

      -- Default action when selecting a file
      formatters = {
        file = {
          filename_first = true,
        },
      },
      -- Default keymaps for all pickers
      win = {
        -- Input window: search/filter bar at top of picker
        input = {
          keys = {
            -- Note: using autocmd below to disable conflicting keymaps in pickers
            ['t'] = { 'tab', mode = { 'n' } },
            ['h'] = { 'edit_split', mode = { 'n' } },
            ['v'] = { 'edit_vsplit', mode = { 'n' } },
            ['w'] = { { 'pick_win', 'jump' }, mode = { 'n' } },  -- Also try pick_win on Enter from input
            ['<CR>'] = { { 'pick_win', 'jump' }, mode = { 'i' } },
          },
        },
        -- Could not get the following to work as expected
        -- -- List window: results/file list in picker (applies to all pickers: files, grep, etc.)
        -- list = {
        --   keys = {
        --     ['<CR>'] = 'pick_win',   -- Enter: pick and choose window
        --     ['t'] = 'tab',       -- Ctrl-t: open in tab
        --     ['h'] = 'edit_split',-- Ctrl-h: open in horizontal split
        --     ['v'] = 'edit_vsplit',-- Ctrl-v: open in vertical split
        --    },
        -- },
      },
      -- Source-specific configurations
      sources = {
        -- Explorer source: file tree browser (uses its own keybindings)
        explorer = {
          enabled = true,
          hidden = true,
          auto_close = true,
          --supports_live = true,
          --tree = true,
          watch = true,
          --diagnostics = true,
          --diagnostics_open = false,
          git_status = true,
          git_status_open = false,
          git_untracked = true,
          --follow_file = true,
          -- Explorer list window: tree view with files/directories
          win = {
            list = {
              keys = {
                ['<CR>'] = { { 'pick_win', 'jump' }, mode = { 'n', 'x' } },
                ['w'] = { { 'pick_win', 'jump' }, mode = { 'n', 'x' } },
                ['t'] = 'tab',
                ['v'] = 'edit_vsplit',
                ['<c-s>'] = 'edit_split',
                -- Keep explorer's native keybindings
                ['l'] = 'confirm',         -- l: open file
                ['h'] = 'explorer_close',  -- h: close directory
                ['a'] = 'explorer_add',
                ['d'] = 'explorer_del',
                ['r'] = 'explorer_rename',
                ['c'] = 'explorer_copy',
                ['m'] = 'explorer_move',
                ['y'] = { 'explorer_yank', mode = { 'n', 'x' } },
                ['p'] = 'explorer_paste',
              },
            },
          },
        },
      },
    },
    notifier = { enabled = false }, -- Disabled to prevent interference with :messages
    quickfile = { enabled = true },
    words = { enabled = true },
    lazygit = {
      -- your lazygit configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
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
          { icon = " ", key = "e", desc = "Folder Explorer", action = ":lua Snacks.dashboard.pick('explorer')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", action = function() require("persistence").load() end },
          { icon = " ", key = "S", desc = "Pick Session", action = function()
            local sessions_dir = vim.fn.stdpath('state') .. '/sessions/'

            -- Debug: show the path being checked
            print("Looking for sessions in: " .. sessions_dir)
            print("Directory exists: " .. tostring(vim.fn.isdirectory(sessions_dir)))

            if vim.fn.isdirectory(sessions_dir) == 0 then
              vim.notify("No sessions directory found at:\n" .. sessions_dir .. "\n\nSessions will be created when you exit nvim from a project directory.", vim.log.levels.INFO)
              return
            end

            -- List ALL files first
            local all_files = vim.fn.readdir(sessions_dir)
            print("All files in directory: " .. vim.inspect(all_files))

            -- Filter for .vim or .lua files
            -- Note: filenames contain % characters (URL-encoded paths), so we can't use patterns with %
            local files = vim.tbl_filter(function(name)
              return name:sub(-4) == ".vim" or name:sub(-4) == ".lua"
            end, all_files)            -- Debug: show what files were found
            print("Found " .. #files .. " session files matching pattern")
            print("Session files: " .. vim.inspect(files))

            if #files == 0 then
              vim.notify("No sessions found in:\n" .. sessions_dir .. "\n\nTip: Sessions are auto-saved when you exit nvim.\nJust work in a directory and exit, then reopen nvim to see the session here.", vim.log.levels.INFO)
              return
            end
            -- Use vim.ui.select to pick a session
            vim.ui.select(files, {
              prompt = "Select session to restore:",
              format_item = function(item)
                return item:gsub('%%', '/'):gsub('%.lua$', ''):gsub('%.vim$', '')
              end,
            }, function(choice)
              if choice then
                local full_path = sessions_dir .. choice
                vim.cmd('source ' .. vim.fn.fnameescape(full_path))
              end
            end)
          end },
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
        function()
          local sessions_dir = vim.fn.stdpath('state') .. '/sessions/'
          local sessions = {}

          if vim.fn.isdirectory(sessions_dir) == 1 then
            -- Get all files and filter for .vim or .lua extensions
            -- Note: filenames contain % characters (URL-encoded paths), so we can't use Lua patterns with %
            local all_files = vim.fn.readdir(sessions_dir)
            local files = vim.tbl_filter(function(name)
              return name:sub(-4) == ".vim" or name:sub(-4) == ".lua"
            end, all_files)

            -- Sort by modification time
            table.sort(files, function(a, b)
              local stat_a = vim.loop.fs_stat(sessions_dir .. a)
              local stat_b = vim.loop.fs_stat(sessions_dir .. b)
              if stat_a and stat_b then
                return stat_a.mtime.sec > stat_b.mtime.sec
              end
              return false
            end)

            -- Create items for up to 5 sessions
            for i = 1, math.min(5, #files) do
              local file = files[i]
              local display_name = file:gsub('%%', '/'):gsub('%.lua$', ''):gsub('%.vim$', '')
              local full_path = sessions_dir .. file
              table.insert(sessions, {
                file = display_name,
                icon = "file",
                action = function()
                  vim.cmd('source ' .. vim.fn.fnameescape(full_path))
                end,
                autokey = true,
              })
            end
          end

          -- Return nothing if no sessions, or return section with title and items
          if #sessions == 0 then
            return nil
          end

          return {
            pane = 2,
            icon = " ",
            title = "Recent Sessions",
            indent = 2,
            padding = 1,
            sessions,
          }
        end,
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
  -- Note: Most keymaps are now in keymaps.lua following the new hierarchical structure
  -- These are kept here for lazy-loading the plugin
  keys = {
    { '<leader>sh', function() require('snacks').picker.help() end, desc = 'Search help' },
    { '<leader>sk', function() require('snacks').picker.keymaps() end, desc = 'Search keymaps' },
    { '<leader>sf', function() require('snacks').picker.files() end, desc = 'Search files' },
    { '<leader>ss', function() require('snacks').picker.smart() end, desc = 'Smart search' },
    { '<leader>sw', function() require('snacks').picker.grep_word() end, desc = 'Search current word' },
    { '<leader>sg', function() require('snacks').picker.grep() end, desc = 'Search by grep' },
    { '<leader>sd', function() require('snacks').picker.diagnostics() end, desc = 'Search diagnostics' },
    { '<leader>sr', function() require('snacks').picker.recent() end, desc = 'Recent files' },
    { '<leader>sc', function()
      require('snacks').picker.files({ cwd = vim.fn.stdpath('config') })
    end, desc = 'Config files' },
    { '<leader>s/', function() require('snacks').picker.lines() end, desc = 'Search in buffer' },
    { '<leader>sof', function()
      require('snacks').picker.grep({ open_only = true })
    end, desc = 'Search in open files' },
    { '<leader>sbl', function() require('snacks').picker.buffers() end, desc = 'Buffer list' },
    { '<leader>sp', function() require('snacks').picker.commands() end, desc = 'Command palette' },
    -- VIP keymaps (also defined in keymaps.lua but need to be here for lazy-loading)
    { '<leader>ff', function() require('snacks').picker.grep() end, desc = 'Find in project' },
    { '<leader>se', function() require('snacks').picker.explorer() end, desc = 'Show explorer' },
    { '<leader>gg', function() require('snacks').lazygit() end, desc = 'Lazygit' },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
    -- Setup autocmd to disable vim keybindings that conflict with picker keys
    vim.api.nvim_create_autocmd('User', {
      pattern = 'SnacksPickerOpen',
      callback = function()
        local picker_buf = vim.api.nvim_get_current_buf()
        -- Disable only the keys we're using for picker actions (t, h, v, w)
        -- This prevents vim defaults from interfering (t=till, h=left, v=visual, w=word)
        local keys_to_disable = { 't', 'h', 'v', 'w' }
        for _, key in ipairs(keys_to_disable) do
          pcall(vim.keymap.set, 'n', key, '<Nop>', { buffer = picker_buf, noremap = true })
        end
      end,
    })
  end,
}