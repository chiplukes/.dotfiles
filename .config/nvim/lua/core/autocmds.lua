-- lua/core/autocmds.lua
-- All autocommands centralized
local M = {}

-- [[ Basic Autocommands ]]
-- See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- =============================================================================
-- Enhanced Autocommands for Development (Phase 2)
-- =============================================================================

-- Python-specific enhancements
vim.api.nvim_create_augroup('PythonEnhancements', { clear = true })

-- Auto-organize imports on save for Python
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'PythonEnhancements',
  pattern = '*.py',
  callback = function()
    -- Only organize imports if isort or ruff is available
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == 'basedpyright' or client.name == 'pyright' then
        -- Try to organize imports via LSP code action
        vim.lsp.buf.code_action({
          context = { only = { 'source.organizeImports' } },
          apply = true,
        })
        break
      end
    end
  end,
})

-- Auto-add docstrings for Python functions (when cursor is on function line)
vim.api.nvim_create_autocmd('FileType', {
  group = 'PythonEnhancements',
  pattern = 'python',
  callback = function()
    -- Add keymap for docstring generation (under <leader>cp)
    vim.keymap.set('n', '<leader>cpd', function()
      local line = vim.api.nvim_get_current_line()
      local row = vim.api.nvim_win_get_cursor(0)[1]

      -- Check if current line contains a function definition
      if line:match('^%s*def%s+') then
        local indent = line:match('^(%s*)')
        local docstring = {
          indent .. '"""',
          indent .. 'TODO: Add function description',
          indent .. '"""',
          ''
        }
        vim.api.nvim_buf_set_lines(0, row, row, false, docstring)
        -- Move cursor to docstring content
        vim.api.nvim_win_set_cursor(0, { row + 2, #indent + 4 })
      end
    end, { desc = 'Add docstring', buffer = true })
  end,
})

-- Verilog/SystemVerilog enhancements
vim.api.nvim_create_augroup('VerilogEnhancements', { clear = true })

-- Auto-format Verilog on save (with size limit for performance)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'VerilogEnhancements',
  pattern = { '*.v', '*.sv', '*.vh', '*.svh' },
  callback = function()
    local line_count = vim.api.nvim_buf_line_count(0)
    -- Only auto-format smaller files to avoid performance issues
    if line_count <= 500 then
      require('conform').format({
        async = false,
        timeout_ms = 3000,
        bufnr = 0
      })
    else
      vim.notify('File too large for auto-format. Use <leader>cfb to format manually.', vim.log.levels.INFO)
    end
  end,
})

-- Enhanced Verilog module instantiation helper
vim.api.nvim_create_autocmd('FileType', {
  group = 'VerilogEnhancements',
  pattern = { 'verilog', 'systemverilog' },
  callback = function()
    -- Add keymap for port connection helper
    vim.keymap.set('n', '<leader>vp', function()
      local word = vim.fn.expand('<cword>')
      local template = {
        '.' .. word .. '(' .. word .. '),',
      }
      vim.api.nvim_put(template, 'l', true, true)
    end, { desc = '[V]erilog [P]ort Connection', buffer = true })

    -- Add keymap for wire declaration
    vim.keymap.set('n', '<leader>vw', function()
      local word = vim.fn.expand('<cword>')
      vim.ui.input({ prompt = 'Wire width (default 1): ' }, function(width)
        width = width or '1'
        local wire_decl = string.format('wire [%s-1:0] %s;', width, word)
        vim.api.nvim_put({wire_decl}, 'l', true, true)
      end)
    end, { desc = '[V]erilog [W]ire Declaration', buffer = true })
  end,
})

-- Enhanced LSP workspace management
vim.api.nvim_create_augroup('LSPWorkspace', { clear = true })

-- Auto-detect Python virtual environments
vim.api.nvim_create_autocmd('BufEnter', {
  group = 'LSPWorkspace',
  pattern = '*.py',
  callback = function()
    local cwd = vim.fn.getcwd()
    local venv_paths = {
      cwd .. '/.venv',
      cwd .. '/venv',
    }

    -- Only check for project venvs, don't fall back to ~/.venv
    -- as it may conflict with Neovim's own python provider
    for _, path in ipairs(venv_paths) do
      if vim.fn.isdirectory(path) == 1 then
        vim.env.VIRTUAL_ENV = path
        local python_path = path .. (vim.fn.has('win32') == 1 and '/Scripts/python.exe' or '/bin/python')
        if vim.fn.executable(python_path) == 1 then
          vim.g.python3_host_prog = python_path
          -- Notify user about detected virtual environment
          vim.notify('Detected project virtual environment: ' .. path, vim.log.levels.INFO)
          break
        end
      end
    end
  end,
})

-- Auto-save enabled (format on save disabled to prevent auto-formatting)
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
  group = vim.api.nvim_create_augroup('AutoSave', { clear = true }),
  pattern = { '*.py', '*.lua', '*.js', '*.ts', '*.json', '*.md' }, -- Extended file type support
  callback = function()
    -- Auto-save after 3 seconds of inactivity (increased from 2s for better performance)
    vim.defer_fn(function()
      if vim.bo.modified and vim.bo.buftype == '' then
        vim.cmd('silent write')
      end
    end, 3000)
  end,
})

return M

-- -- Open Snacks file picker when Neovim is started with a single directory argument
-- vim.api.nvim_create_autocmd('VimEnter', {
--   desc = 'Open Snacks picker when starting with directory (e.g. nvim .)',
--   callback = function()
--     -- Only act when exactly one argument is passed and it's a directory
--     if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
--       local dir = vim.fn.fnamemodify(vim.fn.argv(0), ':p')
--       -- Move to the directory so relative operations work as expected
--       pcall(vim.cmd, 'cd ' .. vim.fn.fnameescape(dir))
--       -- Try to open the Snacks files picker; fall back silently if Snacks is not available
--       pcall(function()
--         require('snacks').picker.files({ cwd = dir })
--       end)
--     end
--   end,
-- })

-- =============================================================================
-- Windows ShaDa Cleanup (Fix for E138 error on exit)
-- =============================================================================
-- On Windows, Neovim sometimes leaves behind .tmp files in the ShaDa directory
-- This causes "E138: All ... files exist, cannot write ShaDa file!" errors
-- This cleans them up on startup and before exiting
if vim.fn.has('win32') == 1 then
  local function clean_shada_tmp()
    local shada_dir = vim.fn.stdpath('data') .. '\\shada'
    local pattern = shada_dir .. '\\main.shada.tmp.*'

    for _, file in ipairs(vim.fn.glob(pattern, false, true)) do
      os.remove(file)
    end
  end

  -- Clean up on startup
  clean_shada_tmp()

  -- Clean up before exiting
  vim.api.nvim_create_autocmd('VimLeavePre', {
    desc = 'Clean up ShaDa temporary files on Windows',
    callback = clean_shada_tmp,
  })
end