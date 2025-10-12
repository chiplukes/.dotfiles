-- lua/core/learn.lua
-- Learning and debugging utilities for Neovim configuration

local M = {}

-- =============================================================================
-- Debugging Utilities
-- =============================================================================

--- Print a message to the command line (visible with :messages)
---@param ... any Values to print
function M.print(...)
  local objects = {}
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end
  print(table.concat(objects, ' '))
end

--- Print to a file for persistent debugging
---@param filename string File to write to (relative to config dir)
---@param ... any Values to print
function M.print_to_file(filename, ...)
  local config_dir = vim.fn.stdpath('config')
  local filepath = config_dir .. '/' .. filename

  local objects = {}
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end

  local timestamp = os.date('%Y-%m-%d %H:%M:%S')
  local message = string.format('[%s] %s\n', timestamp, table.concat(objects, ' '))

  local file = io.open(filepath, 'a')
  if file then
    file:write(message)
    file:close()
    vim.notify('Logged to: ' .. filepath, vim.log.levels.INFO)
  else
    vim.notify('Failed to write to: ' .. filepath, vim.log.levels.ERROR)
  end
end

--- Show a notification with different levels
---@param msg string Message to show
---@param level? string Level: 'info', 'warn', 'error', 'debug' (default: 'info')
function M.notify(msg, level)
  local levels = {
    info = vim.log.levels.INFO,
    warn = vim.log.levels.WARN,
    error = vim.log.levels.ERROR,
    debug = vim.log.levels.DEBUG,
  }
  vim.notify(msg, levels[level] or vim.log.levels.INFO)
end

--- Inspect and print a value in a floating window
---@param value any Value to inspect
---@param title? string Optional title for the window
function M.inspect(value, title)
  local content = vim.inspect(value)
  local lines = vim.split(content, '\n')

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = 'lua'
  vim.bo[buf].bufhidden = 'wipe'

  local width = math.min(120, vim.o.columns - 4)
  local height = math.min(40, vim.o.lines - 4)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    border = 'rounded',
    title = title or ' Inspector ',
    title_pos = 'center',
    style = 'minimal',
  })

  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

--- Show the value under cursor in a floating window
function M.inspect_cursor()
  local word = vim.fn.expand('<cword>')
  local value = _G[word] or vim[word]
  if value then
    M.inspect(value, ' ' .. word .. ' ')
  else
    vim.notify('No global or vim.' .. word .. ' found', vim.log.levels.WARN)
  end
end

--- Profile a function and show execution time
---@param fn function Function to profile
---@param ... any Arguments to pass to the function
---@return any result Result of the function
function M.profile(fn, ...)
  local start = vim.loop.hrtime()
  local result = fn(...)
  local duration = (vim.loop.hrtime() - start) / 1e6 -- Convert to milliseconds
  M.notify(string.format('Execution time: %.2f ms', duration), 'info')
  return result
end

-- =============================================================================
-- Neovim Information Utilities
-- =============================================================================

--- Show current buffer information
function M.show_buffer_info()
  local buf = vim.api.nvim_get_current_buf()
  local info = {
    bufnr = buf,
    name = vim.api.nvim_buf_get_name(buf),
    filetype = vim.bo[buf].filetype,
    modified = vim.bo[buf].modified,
    buftype = vim.bo[buf].buftype,
    lines = vim.api.nvim_buf_line_count(buf),
    loaded = vim.api.nvim_buf_is_loaded(buf),
    valid = vim.api.nvim_buf_is_valid(buf),
  }
  M.inspect(info, ' Buffer Info ')
end

--- Show current window information
function M.show_window_info()
  local win = vim.api.nvim_get_current_win()
  local info = {
    winnr = win,
    buffer = vim.api.nvim_win_get_buf(win),
    width = vim.api.nvim_win_get_width(win),
    height = vim.api.nvim_win_get_height(win),
    cursor = vim.api.nvim_win_get_cursor(win),
    tabpage = vim.api.nvim_win_get_tabpage(win),
  }
  M.inspect(info, ' Window Info ')
end

--- Show all active LSP clients
function M.show_lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify('No LSP clients attached', vim.log.levels.WARN)
    return
  end

  local info = {}
  for _, client in ipairs(clients) do
    table.insert(info, {
      name = client.name,
      id = client.id,
      root_dir = client.config.root_dir,
      filetypes = client.config.filetypes,
    })
  end
  M.inspect(info, ' LSP Clients ')
end

--- Show all loaded plugins
function M.show_plugins()
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify('Lazy.nvim not loaded', vim.log.levels.ERROR)
    return
  end

  local plugins = lazy.plugins()
  local info = {}
  for _, plugin in ipairs(plugins) do
    table.insert(info, {
      name = plugin.name,
      loaded = plugin._.loaded ~= nil,
      dir = plugin.dir,
    })
  end
  M.inspect(info, ' Plugins ')
end

--- Show highlight group under cursor
function M.show_highlight()
  local result = vim.treesitter.get_captures_at_cursor(0)
  if #result == 0 then
    vim.notify('No treesitter highlight', vim.log.levels.WARN)
  else
    M.inspect(result, ' Highlight Groups ')
  end
end

--- Show all keymaps for current buffer
---@param mode? string Mode to show keymaps for (default: 'n')
function M.show_keymaps(mode)
  mode = mode or 'n'
  local buf = vim.api.nvim_get_current_buf()
  local keymaps = vim.api.nvim_buf_get_keymap(buf, mode)

  if #keymaps == 0 then
    -- Try global keymaps
    keymaps = vim.api.nvim_get_keymap(mode)
  end

  local info = {}
  for _, map in ipairs(keymaps) do
    table.insert(info, {
      lhs = map.lhs,
      rhs = map.rhs or map.callback,
      desc = map.desc,
      buffer = map.buffer,
    })
  end
  M.inspect(info, string.format(' Keymaps (%s mode) ', mode))
end

--- Show runtime paths
function M.show_runtimepath()
  local paths = vim.api.nvim_list_runtime_paths()
  M.inspect(paths, ' Runtime Paths ')
end

--- Show all autocommands for current buffer
function M.show_autocmds()
  local buf = vim.api.nvim_get_current_buf()
  local autocmds = vim.api.nvim_get_autocmds({ buffer = buf })
  M.inspect(autocmds, ' Buffer Autocommands ')
end

--- Show Neovim options
function M.show_options()
  local options = {
    -- General
    number = vim.o.number,
    relativenumber = vim.o.relativenumber,
    cursorline = vim.o.cursorline,
    wrap = vim.o.wrap,
    scrolloff = vim.o.scrolloff,
    sidescrolloff = vim.o.sidescrolloff,

    -- Tabs and spaces
    tabstop = vim.o.tabstop,
    shiftwidth = vim.o.shiftwidth,
    expandtab = vim.o.expandtab,
    smartindent = vim.o.smartindent,

    -- Search
    ignorecase = vim.o.ignorecase,
    smartcase = vim.o.smartcase,
    hlsearch = vim.o.hlsearch,
    incsearch = vim.o.incsearch,

    -- UI
    termguicolors = vim.o.termguicolors,
    signcolumn = vim.o.signcolumn,
    colorcolumn = vim.o.colorcolumn,
    list = vim.o.list,

    -- Files
    backup = vim.o.backup,
    writebackup = vim.o.writebackup,
    swapfile = vim.o.swapfile,
    undofile = vim.o.undofile,

    -- Completion
    completeopt = vim.o.completeopt,
    pumheight = vim.o.pumheight,

    -- Timing
    updatetime = vim.o.updatetime,
    timeoutlen = vim.o.timeoutlen,

    -- Splits
    splitright = vim.o.splitright,
    splitbelow = vim.o.splitbelow,
  }
  M.inspect(options, ' Neovim Options ')
end

-- =============================================================================
-- Code Execution Utilities
-- =============================================================================

--- Execute current line as Lua code
function M.exec_current_line()
  local line = vim.api.nvim_get_current_line()
  local ok, result = pcall(loadstring('return ' .. line))

  -- Force redraw to flush output
  vim.cmd('redraw')

  if ok then
    vim.schedule(function()
      M.inspect(result, ' Result ')
    end)
  else
    -- Try without return
    ok, result = pcall(loadstring(line))
    vim.cmd('redraw')

    vim.schedule(function()
      if ok then
        vim.notify('Executed successfully (check :messages for output)', vim.log.levels.INFO)
      else
        vim.notify('Error: ' .. tostring(result), vim.log.levels.ERROR)
      end
    end)
  end
end

--- Execute visual selection as Lua code
function M.exec_visual_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

  local code = table.concat(lines, '\n')

  -- Try to load and execute the code
  local chunk, load_err = loadstring(code)
  if not chunk then
    vim.notify('Syntax error: ' .. tostring(load_err), vim.log.levels.ERROR)
    return
  end

  -- Execute the code
  local ok, result = pcall(chunk)

  -- Force a redraw to flush any print output to :messages
  vim.cmd('redraw')

  -- Defer notification to ensure print output is fully processed
  vim.schedule(function()
    if ok then
      -- Only show result if it's not nil
      if result ~= nil then
        M.inspect(result, ' Result ')
      else
        vim.notify('Code executed successfully (check :messages for output)', vim.log.levels.INFO)
      end
    else
      vim.notify('Runtime error: ' .. tostring(result), vim.log.levels.ERROR)
    end
  end)
end

-- =============================================================================
-- Python Execution Utilities
-- =============================================================================

--- Execute current line as Python code
function M.exec_python_line()
  local line = vim.api.nvim_get_current_line()

  -- Get Python executable from Neovim's python3_host_prog or fallback to PATH
  local python_cmd = vim.g.python3_host_prog or vim.fn.exepath('python3') or vim.fn.exepath('python')
  if python_cmd == '' or python_cmd == vim.NIL then
    vim.notify('Python executable not found. Set g:python3_host_prog or ensure python is in PATH', vim.log.levels.ERROR)
    return
  end

  -- Execute the line (escape quotes for command line)
  local escaped_line = line:gsub('"', '\\"'):gsub('\n', '\\n')
  local output = vim.fn.system('"' .. python_cmd .. '" -c "' .. escaped_line .. '"')

  vim.schedule(function()
    if vim.v.shell_error == 0 then
      if output ~= '' then
        print(output)
      end
      vim.notify('Python executed successfully (check :messages for output)', vim.log.levels.INFO)
    else
      vim.notify('Python error: ' .. output, vim.log.levels.ERROR)
    end
  end)
end

--- Execute visual selection as Python code
function M.exec_python_selection()
  -- Get visual selection
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)

  -- Get Python executable from Neovim's python3_host_prog or fallback to PATH
  local python_cmd = vim.g.python3_host_prog or vim.fn.exepath('python3') or vim.fn.exepath('python')
  if python_cmd == '' or python_cmd == vim.NIL then
    vim.notify('Python executable not found. Set g:python3_host_prog or ensure python is in PATH', vim.log.levels.ERROR)
    return
  end

  -- Write code to a temp file
  local temp_file = vim.fn.tempname() .. '.py'
  vim.fn.writefile(lines, temp_file)

  -- Execute the file (quote the executable path for Windows paths with spaces)
  local output = vim.fn.system('"' .. python_cmd .. '" "' .. temp_file .. '"')

  -- Clean up temp file
  vim.fn.delete(temp_file)

  vim.schedule(function()
    if vim.v.shell_error == 0 then
      if output ~= '' then
        print(output)
      end
      vim.notify('Python executed successfully (check :messages for output)', vim.log.levels.INFO)
    else
      vim.notify('Python error: ' .. output, vim.log.levels.ERROR)
    end
  end)
end

--- Reload current module (useful for config development)
function M.reload_module()
  local buf_name = vim.api.nvim_buf_get_name(0)

  -- Try to extract module name from file path
  local lua_dir = vim.fn.stdpath('config') .. '/lua/'
  if buf_name:match(lua_dir) then
    local module_path = buf_name:gsub(lua_dir, ''):gsub('%.lua$', ''):gsub('/', '.')

    -- Unload the module
    package.loaded[module_path] = nil

    -- Reload it
    local ok, result = pcall(require, module_path)
    if ok then
      vim.notify('Reloaded: ' .. module_path, vim.log.levels.INFO)
      if result then
        M.inspect(result, ' Module: ' .. module_path .. ' ')
      end
    else
      vim.notify('Error reloading: ' .. tostring(result), vim.log.levels.ERROR)
    end
  else
    vim.notify('Not a Lua module in config', vim.log.levels.WARN)
  end
end

-- =============================================================================
-- Learning Dashboard
-- =============================================================================

--- Create a learning/debugging dashboard
function M.open_dashboard()
  local snacks = require('snacks')

  snacks.dashboard.open({
    preset = {
      header = [[
╭─────────────────────────────────────────────────────╮
│           Neovim Learning & Debug Tools             │
╰─────────────────────────────────────────────────────╯
      ]],
      keys = {
        { icon = ' ', key = 'P', desc = 'Lua Playground', action = ':Playground' },
        { icon = ' ', key = 'b', desc = 'Buffer Info', action = function() M.show_buffer_info() end },
        { icon = ' ', key = 'w', desc = 'Window Info', action = function() M.show_window_info() end },
        { icon = ' ', key = 'L', desc = 'LSP Clients', action = function() M.show_lsp_clients() end },
        { icon = ' ', key = 'p', desc = 'Loaded Plugins', action = function() M.show_plugins() end },
        { icon = ' ', key = 'K', desc = 'Keymaps (normal)', action = function() M.show_keymaps('n') end },
        { icon = ' ', key = 'h', desc = 'Highlight Under Cursor', action = function() M.show_highlight() end },
        { icon = ' ', key = 'a', desc = 'Autocommands', action = function() M.show_autocmds() end },
        { icon = ' ', key = 'r', desc = 'Runtime Paths', action = function() M.show_runtimepath() end },
        { icon = ' ', key = 'm', desc = 'Messages', action = ':messages' },
        { icon = ' ', key = 'c', desc = 'Checkhealth', action = ':checkhealth' },
        { icon = ' ', key = 's', desc = 'Startup Time', action = ':Lazy profile' },
        { icon = ' ', key = 'o', desc = 'Options', action = function() M.show_options() end },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
  })
end

-- =============================================================================
-- Setup Function
-- =============================================================================

function M.setup()
  -- Create user commands
  vim.api.nvim_create_user_command('LearnDashboard', function()
    M.open_dashboard()
  end, { desc = 'Open learning dashboard' })

  vim.api.nvim_create_user_command('Playground', function(opts)
    -- Determine which playground to open based on argument or current buffer
    local filetype = opts.args ~= '' and opts.args or vim.bo.filetype
    local playground_path
    local exec_key
    local exec_line_fn
    local exec_selection_fn

    if filetype == 'python' or filetype == 'py' then
      playground_path = vim.fn.stdpath('config') .. '/doc/playground.py'
      exec_key = '<leader>px'
      exec_line_fn = M.exec_python_line
      exec_selection_fn = M.exec_python_selection
    else
      -- Default to Lua
      playground_path = vim.fn.stdpath('config') .. '/doc/playground.lua'
      exec_key = '<leader>lx'
      exec_line_fn = M.exec_current_line
      exec_selection_fn = M.exec_visual_selection
    end

    vim.cmd('edit ' .. playground_path)

    -- Set up buffer-local keymaps for easy execution
    local bufnr = vim.api.nvim_get_current_buf()
    vim.keymap.set('n', exec_key, exec_line_fn, {
      buffer = bufnr,
      desc = 'Execute current line'
    })
    vim.keymap.set('v', exec_key, exec_selection_fn, {
      buffer = bufnr,
      desc = 'Execute selection'
    })

    vim.notify('Playground loaded! Select code and press ' .. exec_key .. ' to execute.', vim.log.levels.INFO)
  end, { nargs = '?', desc = 'Open playground (lua/python/py)' })

  vim.api.nvim_create_user_command('LearnInspect', function(opts)
    local arg = opts.args
    if arg == '' then
      M.inspect_cursor()
    else
      local ok, value = pcall(loadstring('return ' .. arg))
      if ok then
        M.inspect(value, ' ' .. arg .. ' ')
      else
        vim.notify('Error evaluating: ' .. arg, vim.log.levels.ERROR)
      end
    end
  end, { nargs = '?', desc = 'Inspect a value or word under cursor' })

  vim.api.nvim_create_user_command('LearnExec', function(opts)
    local code = opts.args
    local ok, result = pcall(loadstring(code))
    if ok and result ~= nil then
      M.inspect(result, ' Result ')
    elseif ok then
      vim.notify('Executed successfully', vim.log.levels.INFO)
    else
      vim.notify('Error: ' .. tostring(result), vim.log.levels.ERROR)
    end
  end, { nargs = '+', desc = 'Execute Lua code' })

  vim.api.nvim_create_user_command('LearnReload', function()
    M.reload_module()
  end, { desc = 'Reload current module' })

  vim.api.nvim_create_user_command('LearnLog', function(opts)
    M.print_to_file('debug.log', opts.args)
  end, { nargs = '+', desc = 'Log message to debug.log' })

  -- Create keymaps
  vim.keymap.set('n', '<leader>?', M.open_dashboard, { desc = 'Open learning dashboard' })
  vim.keymap.set('n', '<leader>li', M.inspect_cursor, { desc = '[L]earn: [I]nspect word under cursor' })
  vim.keymap.set('n', '<leader>lb', M.show_buffer_info, { desc = '[L]earn: [B]uffer info' })
  vim.keymap.set('n', '<leader>lw', M.show_window_info, { desc = '[L]earn: [W]indow info' })
  vim.keymap.set('n', '<leader>ll', M.show_lsp_clients, { desc = '[L]earn: [L]SP clients' })
  vim.keymap.set('n', '<leader>lp', M.show_plugins, { desc = '[L]earn: [P]lugins' })
  vim.keymap.set('n', '<leader>lk', M.show_keymaps, { desc = '[L]earn: [K]eymaps' })
  vim.keymap.set('n', '<leader>lh', M.show_highlight, { desc = '[L]earn: [H]ighlight groups' })
  vim.keymap.set('n', '<leader>lo', M.show_options, { desc = '[L]earn: [O]ptions' })
  vim.keymap.set('n', '<leader>lr', M.reload_module, { desc = '[L]earn: [R]eload current module' })
  vim.keymap.set('n', '<leader>lx', M.exec_current_line, { desc = '[L]earn: E[x]ec current line' })
  vim.keymap.set('v', '<leader>lx', M.exec_visual_selection, { desc = '[L]earn: E[x]ec selection' })
  vim.keymap.set('n', '<leader>px', M.exec_python_line, { desc = '[P]ython: E[x]ec current line' })
  vim.keymap.set('v', '<leader>px', M.exec_python_selection, { desc = '[P]ython: E[x]ec selection' })

  vim.notify('Learning utilities loaded! Press <leader>? for dashboard', vim.log.levels.INFO)
end

return M
