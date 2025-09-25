-- lua/plugins/debug.lua
-- Lazy-loaded debugging configuration for optimal startup time
return {
  -- =============================================================================
  -- Debug Adapter Protocol (DAP) - Only loads when debugging
  -- =============================================================================
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Python debugger
      'mfussenegger/nvim-dap-python',
    },

    -- Only load when these keys are pressed or commands are run
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
      { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>bp', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
      { '<leader>B', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Debug: Set Breakpoint' },
    },

    cmd = { 'DapUIToggle', 'DapToggleBreakpoint', 'DapContinue', 'DapStepOver', 'DapStepInto', 'DapStepOut' },

    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please read mason-nvim-dap README for more information
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'debugpy',
        },
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      -- require('dap-go').setup {
      --   delve = {
      --     -- On Windows delve must be run attached or it crashes.
      --     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
      --     detached = vim.fn.has 'win32' == 0,
      --   },
      -- }

      -- Python DAP configuration
      require('dap-python').setup('python') -- Uses system python by default

      -- Configure Python debugging for virtual environments
      if vim.fn.executable('python') == 1 then
        require('dap-python').setup('python')
      end

      -- Add Python configuration for debugging
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
              return cwd .. '/venv/bin/python'
            elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
              return cwd .. '/.venv/bin/python'
            elseif vim.fn.executable(cwd .. '/venv/Scripts/python.exe') == 1 then
              return cwd .. '/venv/Scripts/python.exe'
            elseif vim.fn.executable(cwd .. '/.venv/Scripts/python.exe') == 1 then
              return cwd .. '/.venv/Scripts/python.exe'
            else
              return '/usr/bin/python'
            end
          end,
        },
      }
    end,
  },
}