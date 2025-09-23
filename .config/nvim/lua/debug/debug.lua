-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {

  -- =============================================================================
  -- Python Debugger Configuration (DAP - Debug Adapter Protocol)
  -- =============================================================================
    'mfussenegger/nvim-dap',
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
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with reasonable debug configurations
        automatic_setup = true,
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please read mason-nvim-dap README for more information
        ensure_installed = {
          'debugpy', -- Python
        },
      }

      -- Basic debugging keymaps, feel free to change to your liking!
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

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

      -- Python debugger setup with virtual environment detection
      local function get_python_path()
        -- Check for VIRTUAL_ENV environment variable
        local venv_path = vim.fn.getenv('VIRTUAL_ENV')
        if venv_path and venv_path ~= vim.NIL then
          return venv_path .. (vim.fn.has('win32') == 1 and '\\Scripts\\python.exe' or '/bin/python')
        end

        -- Check for local .venv directory
        local cwd = vim.fn.getcwd()
        local venv_dirs = { '.venv', 'venv', '.env', 'env' }

        for _, venv_dir in ipairs(venv_dirs) do
          local local_venv = cwd .. '/' .. venv_dir
          if vim.fn.isdirectory(local_venv) == 1 then
            return local_venv .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')
          end
        end

        -- Check for conda environment
        local conda_env = vim.fn.getenv('CONDA_DEFAULT_ENV')
        if conda_env and conda_env ~= vim.NIL and conda_env ~= 'base' then
          local conda_path = vim.fn.getenv('CONDA_PREFIX')
          if conda_path and conda_path ~= vim.NIL then
            return conda_path .. (vim.fn.has('win32') == 1 and '\\python.exe' or '/bin/python')
          end
        end

        -- Check for Poetry virtual environment
        local poetry_venv = vim.fn.system('poetry env info --path 2>/dev/null'):gsub('\n', '')
        if vim.v.shell_error == 0 and poetry_venv and poetry_venv ~= '' then
          return poetry_venv .. (vim.fn.has('win32') == 1 and '\\Scripts\\python.exe' or '/bin/python')
        end

        -- Fallback to system python
        return 'python'
      end

      local python_path = get_python_path()

      -- Install debugpy on-demand when debugging starts
      local function ensure_debugpy_on_debug(python_executable, callback)
        if python_executable == 'python' then
          -- Using system Python, assume debugpy is available or user will install manually
          vim.notify('Using system Python - ensure debugpy is installed globally', vim.log.levels.INFO)
          if callback then callback() end
          return
        end

        -- Check if debugpy is installed
        local check_cmd = python_executable .. ' -c "import debugpy; print(debugpy.__version__)"'
        local result = vim.fn.system(check_cmd)

        if vim.v.shell_error ~= 0 then
          -- debugpy not found - install it
          vim.notify('🐍 debugpy not found - installing for debugging...', vim.log.levels.WARN)
          print('=== DEBUGPY INSTALLATION ===')
          print('debugpy required for debugging - installing...')

          -- Detect if this is a uv environment by checking if pip module is available
          local pip_check_cmd = python_executable .. ' -c "import pip"'
          local pip_available = vim.fn.system(pip_check_cmd)
          local has_pip = vim.v.shell_error == 0

          local install_cmd
          if has_pip then
            -- Standard virtual environment with pip
            install_cmd = python_executable .. ' -m pip install debugpy'
            print('Running: ' .. install_cmd)
            print('(Using python -m pip)')
          else
            -- Likely a uv environment - try using uv directly
            install_cmd = 'uv add --dev debugpy'
            print('Running: ' .. install_cmd)
            print('(Detected uv environment - using uv add)')
          end

          vim.fn.jobstart(install_cmd, {
            on_stdout = function(_, data)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line and line ~= '' then
                    print('install: ' .. line)
                  end
                end
              end
            end,
            on_stderr = function(_, data)
              if data and #data > 0 then
                for _, line in ipairs(data) do
                  if line and line ~= '' then
                    print('install error: ' .. line)
                  end
                end
              end
            end,
            on_exit = function(_, exit_code)
              if exit_code == 0 then
                print('=== DEBUGPY INSTALLATION SUCCESS ===')
                print('✅ debugpy successfully installed!')
                vim.notify('✅ debugpy installed - starting debugger...', vim.log.levels.INFO)
                if callback then callback() end
              else
                print('=== DEBUGPY INSTALLATION FAILED ===')
                print('❌ Failed to install debugpy (exit code: ' .. exit_code .. ')')
                if has_pip then
                  print('💡 Manual installation: python -m pip install debugpy')
                  vim.notify('❌ debugpy installation failed! Install manually: python -m pip install debugpy', vim.log.levels.ERROR)
                else
                  print('💡 Manual installation: uv add --dev debugpy')
                  vim.notify('❌ debugpy installation failed! Install manually: uv add --dev debugpy', vim.log.levels.ERROR)
                end
              end
            end,
          })
        else
          -- debugpy is already installed
          local version = result:gsub('\n', ''):gsub('\r', '')
          vim.notify('✅ debugpy found (v' .. version .. ') - starting debugger...', vim.log.levels.INFO)
          if callback then callback() end
        end
      end

      require('dap-python').setup(python_path)

      -- Enhanced DAP configuration with on-demand debugpy installation
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = python_path,
          console = 'integratedTerminal',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'python',
          request = 'launch',
          name = 'Launch with arguments',
          program = '${file}',
          pythonPath = python_path,
          console = 'integratedTerminal',
          cwd = '${workspaceFolder}',
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, ' ')
          end,
        },
      }

      -- Override the DAP continue function to ensure debugpy before starting
      local original_continue = dap.continue
      dap.continue = function()
        ensure_debugpy_on_debug(python_path, function()
          original_continue()
        end)
      end

      -- Add DAP event listeners for better error reporting
      dap.listeners.before.event_terminated['error_handler'] = function(session, body)
        if body and body.exitCode and body.exitCode ~= 0 then
          vim.notify(
            string.format('Python debugger exited with code: %d. Check :DapShowLog for details.', body.exitCode),
            vim.log.levels.ERROR
          )
        end
      end

      dap.listeners.before.event_exited['error_handler'] = function(session, body)
        if body and body.exitCode and body.exitCode ~= 0 then
          vim.notify(
            string.format('Python process exited with error code: %d', body.exitCode),
            vim.log.levels.ERROR
          )
        end
      end

      -- Add helpful keybindings for debugging issues
      vim.keymap.set('n', '<leader>dl', function()
        dap.set_log_level('TRACE')
        vim.notify('DAP log level set to TRACE. Use :DapShowLog to view logs.', vim.log.levels.INFO)
      end, { desc = 'Debug: Enable verbose logging' })

      vim.keymap.set('n', '<leader>ds', ':DapShowLog<CR>', { desc = 'Debug: Show DAP log' })

      -- Add command to manually install debugpy
      vim.api.nvim_create_user_command('DebugpyInstall', function()
        ensure_debugpy_on_debug(python_path, function()
          vim.notify('✅ debugpy installation check complete!', vim.log.levels.INFO)
        end)
      end, { desc = 'Install debugpy in current virtual environment' })

      -- Add some helpful debug messages
      vim.notify('Python debugger configured with: ' .. python_path, vim.log.levels.INFO)
      vim.notify('debugpy will be auto-installed when you start debugging', vim.log.levels.INFO)
      vim.notify('Use :DebugpyInstall to install debugpy manually', vim.log.levels.INFO)
    end,

}
