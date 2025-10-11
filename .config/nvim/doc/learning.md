# Learning & Debugging Utilities

This module provides helpful tools for learning and debugging your Neovim configuration.

## Quick Access

- Press `<leader>?` to open the **Learning Dashboard**
- Type `:Playground` to open the **Lua Playground** with interactive examples
- All commands start with `<leader>l` (Learn)

## User Commands

| Command | Description |
|---------|-------------|
| `:Playground` | Open Lua playground with interactive examples |
| `:LearnDashboard` | Open the learning dashboard |
| `:LearnInspect [expr]` | Inspect a value or word under cursor |
| `:LearnExec <code>` | Execute Lua code |
| `:LearnReload` | Reload the current module |
| `:LearnLog <message>` | Log message to `debug.log` |

## Lua Playground

The playground is an interactive file with lots of Lua examples focused on Neovim usage.

### How to Use:

1. Open with `:Playground`
2. Navigate to any code example
3. Select code (visual mode) or place cursor on a line
4. Press `<leader>lx` to execute it
5. Check `:messages` for output

The playground includes examples for:
- Basic Lua syntax
- Neovim API usage
- Working with buffers and windows
- LSP interaction
- File system operations
- Practical examples you can adapt

## Keymaps

### Normal Mode

| Keymap | Description |
|--------|-------------|
| `<leader>?` | Open learning dashboard |
| `<leader>li` | Inspect word under cursor |
| `<leader>lb` | Show buffer info |
| `<leader>lw` | Show window info |
| `<leader>ll` | Show LSP clients |
| `<leader>lp` | Show loaded plugins |
| `<leader>lk` | Show keymaps |
| `<leader>lh` | Show highlight groups under cursor |
| `<leader>lr` | Reload current module |
| `<leader>lx` | Execute current line as Lua |

### Visual Mode

| Keymap | Description |
|--------|-------------|
| `<leader>lx` | Execute visual selection as Lua |

## Examples

### Inspect Values

```vim
" Inspect a variable
:LearnInspect vim.o.runtimepath

" Inspect word under cursor (place cursor on 'vim' and press <leader>li)
vim

" Inspect in floating window
:lua require('core.learn').inspect(vim.lsp.get_clients())
```

### Execute Lua Code

```vim
" Execute a line
:LearnExec print("Hello from Neovim!")

" Execute current line in buffer (press <leader>lx)
print(vim.fn.expand('%'))

" Execute visual selection (select lines, press <leader>lx)
local buf = vim.api.nvim_get_current_buf()
print("Current buffer:", buf)
```

### Debug Logging

```vim
" Log to debug.log file
:LearnLog Starting debug session
:LearnLog Buffer count: 5

" Or in Lua
:lua require('core.learn').print_to_file('debug.log', 'Custom message', { data = 123 })
```

### Reload Modules

```vim
" When editing a config file, reload it (press <leader>lr)
:LearnReload

" Or manually
:lua package.loaded['core.options'] = nil
:lua require('core.options')
```

## Programmatic API

You can use these functions in your own Lua code:

```lua
local learn = require('core.learn')

-- Print to messages
learn.print('Hello', { key = 'value' })

-- Show notification
learn.notify('Something happened', 'info')  -- 'info', 'warn', 'error', 'debug'

-- Inspect in floating window
learn.inspect(vim.api.nvim_list_bufs(), 'All Buffers')

-- Profile a function
learn.profile(function()
  -- Some expensive operation
  vim.fn.system('sleep 0.1')
end)

-- Show various info
learn.show_buffer_info()
learn.show_window_info()
learn.show_lsp_clients()
learn.show_plugins()
learn.show_keymaps('n')  -- 'n', 'i', 'v', etc.
```

## Learning Dashboard Keys

When you open the dashboard (`<leader>?`), these keys are available:

| Key | Action |
|-----|--------|
| `P` | Lua Playground (interactive examples) |
| `b` | Buffer Info |
| `w` | Window Info |
| `l` | LSP Clients |
| `p` | Loaded Plugins |
| `k` | Keymaps (normal mode) |
| `h` | Highlight Under Cursor |
| `a` | Autocommands |
| `r` | Runtime Paths |
| `m` | Messages |
| `c` | Checkhealth |
| `s` | Startup Time (Lazy profile) |
| `o` | Options |
| `q` | Quit |

## Tips

1. **Quick inspection**: Place cursor on any word (like `vim`, `require`, etc.) and press `<leader>li`

2. **Test code snippets**: Write Lua code in any buffer and execute with `<leader>lx`

3. **Debug plugin issues**: Use `<leader>lp` to see which plugins are loaded

4. **Check LSP**: Use `<leader>ll` to see active LSP clients and their config

5. **Learn keymaps**: Press `<leader>lk` to see all available keymaps in current buffer

6. **Persistent logging**: Use `:LearnLog` to log debug info that persists across sessions

7. **Module development**: When editing config files, use `<leader>lr` to reload without restarting Neovim
