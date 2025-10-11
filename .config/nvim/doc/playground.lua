-- Lua Playground for Neovim
-- Select any code block and press <leader>lx to execute it
-- Or place cursor on a line and press <leader>lx to run just that line

-- =============================================================================
-- BASIC LUA SYNTAX
-- =============================================================================

-- Variables and types
local name = "Neovim"
local version = 0.10
local is_awesome = true
local nothing = nil

print("Hello from " .. name .. " " .. version)
print("Is awesome:", is_awesome)

-- Tables (Lua's main data structure)
local config = {
  editor = "Neovim",
  version = 0.10,
  plugins = { "lazy.nvim", "snacks.nvim", "telescope.nvim" },
}


print(vim.inspect(config))

-- Accessing table values
print("Editor:", config.editor)
print("First plugin:", config.plugins[1])  -- Lua arrays are 1-indexed!

-- Functions
local function greet(name)
  return "Hello, " .. name .. "!"
end

print(greet("World"))

-- Anonymous functions
local square = function(x) return x * x end
print("5 squared is", square(5))

-- Conditionals
local hour = tonumber(os.date("%H"))
if hour < 12 then
  print("Good morning!")
elseif hour < 18 then
  print("Good afternoon!")
else
  print("Good evening!")
end

-- Loops
print("Counting to 5:")
for i = 1, 5 do
  print(i)
end

print("\nIterating over plugins:")
for i, plugin in ipairs(config.plugins) do
  print(i, plugin)
end

print("\nIterating over key-value pairs:")
for key, value in pairs(config) do
  print(key, "=", value)
end

-- =============================================================================
-- NEOVIM API BASICS
-- =============================================================================

-- Getting information about current buffer
local buf = vim.api.nvim_get_current_buf()
local buf_name = vim.api.nvim_buf_get_name(buf)
local line_count = vim.api.nvim_buf_line_count(buf)

print("Current buffer:", buf)
print("Buffer name:", buf_name)
print("Line count:", line_count)

-- Getting current window
local win = vim.api.nvim_get_current_win()
local cursor = vim.api.nvim_win_get_cursor(win)
print("Cursor position: line", cursor[1], "col", cursor[2])

-- Reading buffer content
local lines = vim.api.nvim_buf_get_lines(buf, 0, 5, false)
print("First 5 lines:")
for i, line in ipairs(lines) do
  print(i, line)
end

-- Getting the current line
local current_line = vim.api.nvim_get_current_line()
print("Current line:", current_line)

-- Vim options (multiple ways to access)
print("Number enabled:", vim.o.number)
print("Relative number:", vim.opt.relativenumber:get())
print("Tab width:", vim.bo.tabstop)
print("Window width:", vim.wo.number)

-- =============================================================================
-- WORKING WITH BUFFERS
-- =============================================================================

-- List all buffers
local buffers = vim.api.nvim_list_bufs()
print("Total buffers:", #buffers)
for _, b in ipairs(buffers) do
  if vim.api.nvim_buf_is_loaded(b) then
    local name = vim.api.nvim_buf_get_name(b)
    print("Buffer", b, ":", name)
  end
end

-- Get buffer options
local buf_info = {
  filetype = vim.bo.filetype,
  modified = vim.bo.modified,
  readonly = vim.bo.readonly,
  buftype = vim.bo.buftype,
}
print(vim.inspect(buf_info))

-- =============================================================================
-- WORKING WITH WINDOWS
-- =============================================================================

-- List all windows
local windows = vim.api.nvim_list_wins()
print("Total windows:", #windows)
for _, w in ipairs(windows) do
  local buf_in_win = vim.api.nvim_win_get_buf(w)
  local width = vim.api.nvim_win_get_width(w)
  local height = vim.api.nvim_win_get_height(w)
  print(string.format("Window %d: buffer %d, %dx%d", w, buf_in_win, width, height))
end

-- Get window configuration
local win_config = vim.api.nvim_win_get_config(win)
print(vim.inspect(win_config))

-- =============================================================================
-- KEYMAPS
-- =============================================================================

-- Getting keymaps
local normal_maps = vim.api.nvim_get_keymap('n')
print("Total normal mode keymaps:", #normal_maps)

-- Show first few keymaps
for i = 1, math.min(5, #normal_maps) do
  local map = normal_maps[i]
  print(map.lhs, "->", map.rhs or "[function]")
end

-- Check if a specific keymap exists
local space_maps = vim.tbl_filter(function(map)
  return map.lhs:match("^<Space>") or map.lhs:match("^ ")
end, normal_maps)
print("Space-prefixed keymaps:", #space_maps)

-- =============================================================================
-- LSP
-- =============================================================================

-- Get LSP clients for current buffer
local clients = vim.lsp.get_clients({ bufnr = 0 })
print("Active LSP clients:", #clients)
for _, client in ipairs(clients) do
  print("Client:", client.name, "ID:", client.id)
  print("Root dir:", client.config.root_dir)
end

-- Check if any LSP is attached
if #clients > 0 then
  print("LSP is active!")
else
  print("No LSP attached to this buffer")
end

-- =============================================================================
-- FILE SYSTEM
-- =============================================================================

-- Get Neovim directories
local config_dir = vim.fn.stdpath('config')
local data_dir = vim.fn.stdpath('data')
local cache_dir = vim.fn.stdpath('cache')
local state_dir = vim.fn.stdpath('state')

print("Config dir:", config_dir)
print("Data dir:", data_dir)
print("Cache dir:", cache_dir)
print("State dir:", state_dir)

-- Current working directory
local cwd = vim.fn.getcwd()
print("Current working directory:", cwd)

-- Expand paths
local home = vim.fn.expand('~')
local current_file = vim.fn.expand('%')
local current_file_full = vim.fn.expand('%:p')
print("Home:", home)
print("Current file (relative):", current_file)
print("Current file (absolute):", current_file_full)

-- Check if file/directory exists
local function exists(path)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

print("Config exists:", exists(config_dir))
print("Non-existent file:", exists("/this/does/not/exist"))

-- =============================================================================
-- VIM FUNCTIONS
-- =============================================================================

-- Execute vim commands
vim.cmd('echo "Hello from vim.cmd!"')

-- Set options
vim.cmd('set number')
vim.cmd('set relativenumber')

-- Multiple commands at once
vim.cmd([[
  echo "Line 1"
  echo "Line 2"
  echo "Line 3"
]])

-- Common vim functions
print("File type:", vim.fn.expand('%:e'))
print("File name:", vim.fn.expand('%:t'))
print("Current line number:", vim.fn.line('.'))
print("Total lines:", vim.fn.line('$'))
print("Column:", vim.fn.col('.'))

-- =============================================================================
-- NOTIFICATIONS AND MESSAGES
-- =============================================================================

-- Simple print (goes to :messages)
print("This is a simple print")

-- Notifications with levels
vim.notify("Info message", vim.log.levels.INFO)
vim.notify("Warning message", vim.log.levels.WARN)
vim.notify("Error message", vim.log.levels.ERROR)
vim.notify("Debug message", vim.log.levels.DEBUG)

-- Echo (appears on command line)
vim.api.nvim_echo({{"Hello, ", "Normal"}, {"Neovim!", "Title"}}, false, {})

-- =============================================================================
-- AUTOCOMMANDS
-- =============================================================================

-- Create an autocommand
local augroup = vim.api.nvim_create_augroup('PlaygroundExample', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
  group = augroup,
  pattern = '*.lua',
  callback = function()
    print("Entered a Lua buffer!")
  end,
})

-- List autocommands for this group
local autocmds = vim.api.nvim_get_autocmds({ group = 'PlaygroundExample' })
print("Autocommands in group:", #autocmds)
print(vim.inspect(autocmds))

-- Clean up (remove the autocommand group)
vim.api.nvim_del_augroup_by_name('PlaygroundExample')
print("Cleaned up autocommand group")

-- =============================================================================
-- TABLES AND UTILITY FUNCTIONS
-- =============================================================================

-- vim.tbl_* functions for working with tables
local t1 = { a = 1, b = 2 }
local t2 = { b = 3, c = 4 }

-- Extend (merge tables, t2 overwrites t1)
local merged = vim.tbl_extend('force', t1, t2)
print("Merged:", vim.inspect(merged))

-- Deep extend (recursive merge)
local nested1 = { user = { name = "Alice", age = 30 } }
local nested2 = { user = { age = 31, city = "NYC" } }
local deep_merged = vim.tbl_deep_extend('force', nested1, nested2)
print("Deep merged:", vim.inspect(deep_merged))

-- Filter table
local numbers = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
local evens = vim.tbl_filter(function(n) return n % 2 == 0 end, numbers)
print("Even numbers:", vim.inspect(evens))

-- Map table
local doubled = vim.tbl_map(function(n) return n * 2 end, numbers)
print("Doubled:", vim.inspect(doubled))

-- Check if table contains value
print("Contains 5:", vim.tbl_contains(numbers, 5))
print("Contains 99:", vim.tbl_contains(numbers, 99))

-- Count items
print("Count:", vim.tbl_count(t1))

-- Get keys
local keys = vim.tbl_keys(t1)
print("Keys:", vim.inspect(keys))

-- Get values
local values = vim.tbl_values(t1)
print("Values:", vim.inspect(values))

-- =============================================================================
-- STRING OPERATIONS
-- =============================================================================

-- String manipulation
local str = "  Hello, Neovim!  "
print("Original:", str)
print("Trimmed:", vim.trim(str))
print("Upper:", str:upper())
print("Lower:", str:lower())
print("Length:", #str)

-- String splitting
local csv = "apple,banana,cherry"
local fruits = vim.split(csv, ',')
print("Fruits:", vim.inspect(fruits))

-- Pattern matching
local path = "/home/user/config.lua"
local filename = path:match("([^/]+)$")
print("Filename:", filename)

-- String format
local formatted = string.format("%s version %d.%d", "Neovim", 0, 10)
print(formatted)

-- =============================================================================
-- PRACTICAL EXAMPLES
-- =============================================================================

-- Example 1: Count words in current buffer
local function count_words()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, " ")
  local word_count = 0
  for _ in text:gmatch("%S+") do
    word_count = word_count + 1
  end
  print("Word count:", word_count)
  return word_count
end

count_words()

-- Example 2: Get all Lua files in config directory
local function find_lua_files()
  local config = vim.fn.stdpath('config')
  local lua_dir = config .. '/lua'

  -- Use vim.fn.globpath to find files
  local files = vim.fn.globpath(lua_dir, '**/*.lua', false, true)

  print("Found", #files, "Lua files in", lua_dir)
  for i, file in ipairs(files) do
    if i <= 10 then  -- Show first 10
      print(i, file)
    end
  end

  return files
end

find_lua_files()

-- Example 3: Toggle a buffer option
local function toggle_option(option)
  local current = vim.opt[option]:get()
  vim.opt[option] = not current
  print(option, "is now:", not current)
end

-- Uncomment to try:
-- toggle_option('number')
-- toggle_option('relativenumber')

-- Example 4: Create a simple floating window
local function create_float()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 60
  local height = 10

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "╔═══════════════════════════════════════╗",
    "║                                       ║",
    "║     This is a floating window!        ║",
    "║                                       ║",
    "║   Press 'q' or <Esc> to close        ║",
    "║                                       ║",
    "╚═══════════════════════════════════════╝",
  })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    border = 'rounded',
    style = 'minimal',
  })

  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf })

  print("Created floating window:", win)
end

-- Uncomment to try:
-- create_float()

-- Example 5: Get syntax highlighting info under cursor
local function get_highlight_under_cursor()
  local result = vim.treesitter.get_captures_at_cursor(0)
  if #result == 0 then
    print("No treesitter highlight at cursor")
  else
    print("Highlight captures:")
    for _, capture in ipairs(result) do
      print("  -", capture)
    end
  end
end

-- get_highlight_under_cursor()

-- =============================================================================
-- TIPS
-- =============================================================================

--[[
TIPS FOR USING THIS PLAYGROUND:

1. Execute any code:
   - Visual select and press <leader>lx
   - Or press <leader>lx on a single line

2. Inspect values:
   - Place cursor on 'vim' and press <leader>li
   - Or use :LearnInspect vim.api

3. Check results:
   - Use :messages to see print output
   - Or :LearnLog message to log to file

4. Experiment:
   - Modify any example
   - Add your own code
   - Break things and learn!

5. Common patterns:
   - Use vim.inspect() to pretty-print tables
   - Use pcall() to safely call functions
   - Use vim.schedule() for deferred execution

6. Documentation:
   - :help lua-guide
   - :help vim.api
   - :help lua-vim
--]]

print("Playground loaded! Select code and press <leader>lx to execute.")
