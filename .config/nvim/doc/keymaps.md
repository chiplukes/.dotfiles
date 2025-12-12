# Neovim Keymaps Reference

**Generated:** 2025-10-30
**Purpose:** Organized keymap reference for easy lookup and future refactoring

---

## 🌟 VIP Keymaps (No Category Prefix)

These are frequently-used shortcuts that bypass category prefixes for quick access.

| Keymap | Description | File | Repeatable | Notes |
|--------|-------------|------|-------|-------|
| `<leader><leader>` | Repeat last command |n| keymaps.lua | Repeat Previous command |
| `gc` | Toggle comment | |n | Line/block commenting |
| `ge` | Go to next error | |y| VS Code-style error navigation |
| `go` | Go to outline/symbols | keymaps.lua |n| Document symbol outline |
| `K` | goto documentation | lsp_config.lua | n| LSP hover info |
| `sj` | Flash jump (EasyMotion) | flash.lua |n| Quick cursor navigation |
| `<Alt-h>` | Window/buffer left (with wrap) | keymaps.lua |n| Navigate left or previous tab |
| `<Alt-l>` | Window/buffer right (with wrap) | keymaps.lua | n| Navigate right or next tab |
| `<Alt-j>` | Window down | keymaps.lua |n| Navigate to lower window |
| `<Alt-k>` | Window up | keymaps.lua |n| Navigate to upper window |
| `<leader>pr` | Paste from yank register | keymaps.lua | y| Paste last yank (ignores deletes) |
| `<leader>e` | File Explorer | keymaps.lua | n| Shows File Tree |

---

## 📝 Code (`<leader>c`)

Code-related operations: LSP actions, refactoring, formatting, diagnostics.

### Direct Code Actions (no prefix)

| Keymap | Mode | Description | File | Repeatable | Notes |
|--------|------|-------------|------|-------|-------|
| `r` | n | Rename symbol | keymaps.lua | n | LSP rename across project |
| `a` | n | Code action / Quick fix | keymaps.lua | n | Context-sensitive fixes |
| `a` | v | Multi-cursor on all | keymaps.lua | n | Multi-cursor simulation |
| `i` | n | toggle inlay hints | lsp_config.lua | n | Toggle inlay hints |

### Python Specific (`p` prefix)

| Keymap | Mode | Description | File | Notes |
|--------|------|-------------|------|-------|
| `d` | n | Add docstring | autocmds.lua | Generate Python docstring |
| `x` | n | Execute Python line | autocmds.lua | Run current line |
| `x` | v | Execute Python selection | autocmds.lua | Run selected code |

**Note:** For formatting Python code (including selections), use `<leader>cfb` (buffer) or `<leader>cfs` (visual selection).

### Goto Navigation (`g` prefix)

| Subcategory -g | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Goto | `r` | Go to references | lsp_config.lua | Find all references |
| Goto | `d` | Go to definition | lsp_config.lua | Jump to definition |
| Goto | `i` | Go to implementation | lsp_config.lua | Jump to implementation |
| Goto | `D` | Go to declaration | lsp_config.lua | Jump to declaration |
| Goto | `t` | Go to type definition | lsp_config.lua | Jump to type def |

### Diagnostics (`.` prefix)

| Subcategory | Keymap | Description | File | Repeatable | Notes |
|-------------|--------|-------------|------|-------|
| Diagnostic | `n` | next diagnostic | lsp_config.lua | y | Next issue |
| Diagnostic | `p` | previous diagnostic | lsp_config.lua | y | Previous issue |
| Diagnostic | `d` | Diagnostic details | lsp_config.lua | y | Show full details |
| Diagnostic | `e` | Show error messages | (default) | n | Diagnostic float |
| Diagnostic | `q` | Diagnostic quickfix | (default) | n | Quickfix list |
| Diagnostic | `u` | Hide diagnostics | keymaps.lua | n | Undo/hide suggestions |

### Symbols (`s` prefix)

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `d` | Document symbols | lsp_config.lua | Symbol picker for current file |
| `w` | Workspace symbols | lsp_config.lua | Symbol picker for entire project |

### Formatting (`f` prefix)

| Keymap | Mode | Description | File | Notes |
|--------|------|-------------|------|-------|
| `b` | n | Format buffer | lsp_config.lua | Format entire file |
| `s` | v | Format selection | keymaps.lua | Format visual selection |


### 🐛 Debug (`d`)

Debugging operations and breakpoint management.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Breakpoint | `b` | Toggle breakpoint | (lazy) | Toggle BP at line |
| Breakpoint | `B` | Set breakpoint | (lazy) | Set conditional BP | (remove_this)
| Control | `<F5>` | Start/Continue | (lazy) | Begin/resume debugging |
| Control | `<F1>` | Step into | (lazy) | Step into function |
| Control | `<F2>` | Step over | (lazy) | Step over line |
| Control | `<F3>` | Step out | (lazy) | Step out of function |

---


---

## 🔍 Search (`<leader>s`)

File search, grep, and fuzzy finding operations.

**Picker Actions (available in all search pickers):**
- `<CR>` - window picker (select location to open file)
- `w` - window picker (select location to open file)
- `t` - Open in new tab
- `v` - Open in vertical split
- `h` - Open in horizontal split

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Files | `f` | Search files | snacks.lua | Find by filename |
| Files | `r` | Recent files | snacks.lua | Recently opened |
| Files | `c` | Neovim config files | snacks.lua | Search config dir |
| Content | `g` | Search by grep | snacks.lua | Live grep content |
| Content | `w` | Search current word | snacks.lua | Grep word under cursor |
| Content | `/` | Search in buffer | snacks.lua | Fuzzy search current file |
| Content | `of` | Search in open files | snacks.lua | Search across buffers |
| Smart | `s` | Smart search | snacks.lua | Context-aware search |
| Other | `k` | Search keymaps | snacks.lua | Find keybindings |
| Other | `h` | Search help | snacks.lua | Neovim help tags |
| Other | `d` | Search diagnostics | snacks.lua | Find diagnostics |
| Other | `b` | Find buffers | snacks.lua | Open buffer list |
| Command | `p` | Command palette | keymaps.lua | VS Code-style palette |

---

## 📌 Markers/Bookmarks (`<leader>m`)

Marker and bookmark management using marker-groups.nvim.

### Basic Markers

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `a` | Add marker | keymaps.lua | Add new marker |
| `d` | Remove marker | keymaps.lua | Delete marker at cursor |
| `v` | Toggle viewer | keymaps.lua | Show/hide marker drawer |

### Marker Groups (`<leader>mg` prefix)

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `c` | Create group | keymaps.lua | New marker group |
| `s` | Select group | keymaps.lua | Switch active group |
| `r` | Rename group | keymaps.lua | Rename active group |
| `d` | Delete group | keymaps.lua | Remove group |
| `b` | From branch | keymaps.lua | Create group from git branch |

---

## 🪟 Window Management (`<leader>w`)

Window splitting, navigation, and layout management.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Split | `v` | Split vertical | keymaps.lua | Vertical split |
| Split | `c` | Close window | keymaps.lua | Close current |
| Split | `f` | Fullscreen | keymaps.lua | Close other windows |
| Other | `we` | Explorer (netrw) | keymaps.lua | File browser | (remove_this)
| Split | `t` | move to tab | keymaps.lua | Move to New Tab |

---

## 📂 Explorer/Files (`<leader>e`)

File exploration and project navigation.

**Explorer Actions:**
- `<CR>` - Open in current window (default)
- `w` - pick window
- `t` - Open in new tab
- `v` - Open in vertical split
- `h` - Open in horizontal split

---

## 💬 AI/Copilot (`<leader>a`)

AI assistance and code suggestions.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Accept | `y` | Accept suggestion | keymaps.lua | Accept AI completion |

---

## 🎓 Learning/Debug (`<leader>l`)

Learning utilities and config debugging tools.

### Inspection

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Inspect | `i` | Inspect word | learn.lua | Inspect value at cursor |
| Info | `b` | Buffer info | learn.lua | Show buffer details |
| Info | `w` | Window info | learn.lua | Show window details |
| Info | `l` | LSP clients | learn.lua | Active LSP servers |
| Info | `p` | Plugins | learn.lua | Loaded plugins |
| Info | `k` | Keymaps | learn.lua | Show keymaps for mode |
| Info | `h` | Highlight groups | learn.lua | Treesitter highlights |
| Info | `o` | Options | learn.lua | Vim option values |
| Info | `?` | Learning dashboard | learn.lua | Open help dashboard |
| Module | `hr` | Reload module | learn.lua | Hot reload config |

### Code Execution (`x` prefix)

| Keymap | Mode | Description | File | Notes |
|--------|------|-------------|------|-------|
| `l` | n | Execute Lua line | learn.lua | Run current line |
| `l` | v | Execute Lua selection | learn.lua | Run selected code |
| `p` | n | Execute Python line | learn.lua | Run current line |
| `p` | v | Execute Python selection | learn.lua | Run selected code |

---

## 📋 Sessions (`<leader>q`)

Session management and persistence.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Session | `qs` | Restore session | persistence.lua | Load saved session |
| Session | `ql` | Restore last session | persistence.lua | Last session |
| Session | `qd` | Don't save session | persistence.lua | Skip auto-save |

---

## ✨ Git Stuff (`<leader>g`)

Git Stuff

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Misc | `g` | Lazygit | snacks.lua | Git interface |

---

## 🎯 Motion & Navigation

Enhanced movement and text object operations.

### Flash (EasyMotion-style)

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| n/x/o | `sj` | Flash jump | flash.lua | Jump to visible text |
| n/x/o | `S` | Flash treesitter | flash.lua | Jump to TS nodes |
| x/o | `R` | Flash treesitter search | flash.lua | Search TS nodes |
| o | `r` | Remote flash | flash.lua | Remote operations |
| n/x/o | `f/F/t/T` | Enhanced char motion | flash.lua | Flash-enhanced |

### Treesitter Selection

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| n | `<C-Space>` | Init node selection | nvim-treesitter | Start selecting |
| x | `<C-Space>` | Increment to node | nvim-treesitter | Expand to next node |
| x | `<C-S>` | Increment to scope | nvim-treesitter | Expand to scope |
| x | `<M-Space>` | Decrement selection | nvim-treesitter | Shrink selection |

### Text Objects (mini.ai)

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| x/o | `a` | Around textobject | mini.nvim | Outer textobject |
| x/o | `i` | Inside textobject | mini.nvim | Inner textobject |
| x/o | `an` | Around next | mini.nvim | Next outer |
| x/o | `in` | Inside next | mini.nvim | Next inner |
| x/o | `al` | Around last | mini.nvim | Last outer |
| x/o | `il` | Inside last | mini.nvim | Last inner |
| n/x | `g]` | Move right (around) | mini.nvim | Next textobject |
| n/x | `g[` | Move left (around) | mini.nvim | Previous textobject |

### Surround (mini.surround)

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| n | `sa` | Add surrounding | mini.nvim | Add surround |
| n | `sd` | Delete surrounding | mini.nvim | Remove surround |
| n | `sr` | Replace surrounding | mini.nvim | Change surround |
| n | `sf` | Find right surround | mini.nvim | Highlight right |
| n | `sF` | Find left surround | mini.nvim | Highlight left |
| n | `sh` | Highlight surround | mini.nvim | Show surrounding |
| x | `sa` | Add to selection | mini.nvim | Surround visual |
| n | `sdn/sdl` | Delete next/last | mini.nvim | Directional delete |
| n | `srn/srl` | Replace next/last | mini.nvim | Directional replace |

### Alignment (mini.align)

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| v | `ga` | Align by character | utilities.lua | Align on char |
| v | `gA` | Align by regex | utilities.lua | Advanced alignment |

---

## 🔧 Snippets

LuaSnip snippet navigation and expansion.

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| i/s | `<Tab>` | Expand or jump next | luasnip.lua | Navigate forward |
| i/s | `<S-Tab>` | Jump previous | luasnip.lua | Navigate backward |
| i | `<C-E>` | Choose next option | luasnip.lua | Choice node |

---

## 💡 Completion (blink.cmp)

Completion menu navigation (command mode).

| Mode | Keymap | Description | File | Notes |
|------|--------|-------------|------|-------|
| c | `<Tab>` | Next completion | blink.cmp | Navigate down |
| c | `<S-Tab>` | Previous completion | blink.cmp | Navigate up |
| c | `<C-Space>` | Show completions | blink.cmp | Trigger menu |
| c | `<C-Y>` | Accept completion | blink.cmp | Confirm |
| c | `<C-E>` | Cancel completion | blink.cmp | Close menu |
| c | `<C-N>/<C-P>` | Navigate | blink.cmp | Up/Down |

---

## 🔤 Insert Mode

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `<C-K>` | Signature help | lsp_config.lua | Show function signature |
| `<C-S>` | Signature help | (default) | Alternative binding |
| `<C-U>` | Delete to line start | (default) | With undo break |
| `<C-W>` | Delete word | (default) | With undo break |

---

## 🖱️ Visual Mode

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `gc` | Toggle comment | (default) | Line/block comment |
| `gra` | Code action | (default) | Visual code action |
| `<C-.>` | Quick fix | keymaps.lua | VS Code-style |
| `ca` | Cursor on all | keymaps.lua | Multi-cursor visual |

---

## 🔗 Other Defaults

Built-in Neovim mappings (reference only - not customized).

### Quickfix/Location Navigation

| Keymap | Description | Notes |
|--------|-------------|-------|
| `]q/[q` | Next/prev quickfix | Built-in |
| `]Q/[Q` | Last/first quickfix | Built-in |
| `]l/[l` | Next/prev location | Built-in |
| `]L/[L` | Last/first location | Built-in |

### Buffer Navigation

| Keymap | Description | Notes |
|--------|-------------|-------|
| `]b/[b` | Next/prev buffer | Built-in |
| `]B/[B` | Last/first buffer | Built-in |

### Tab Navigation

| Keymap | Description | Notes |
|--------|-------------|-------|
| `]t/[t` | Next/prev tab | Built-in |
| `]T/[T` | Last/first tab | Built-in |

### Argument Navigation

| Keymap | Description | Notes |
|--------|-------------|-------|
| `]a/[a` | Next/prev file | Built-in |
| `]A/[A` | Last/first file | Built-in |

### Space Management

| Keymap | Description | Notes |
|--------|-------------|-------|
| `]<Space>` | Add line below | Built-in |
| `[<Space>` | Add line above | Built-in |

---

## 📝 Notes & TODOs

### Categories to Refactor
- [ ] Move frequently-used LSP goto commands to VIP section
- [ ] Consider shorter bindings for common debug operations
- [ ] Consolidate format keymaps (currently `cf`, `fb`, `rf`)
- [ ] Review Python-specific keymaps for better organization

### Future Considerations
- Add git operations category (`<leader>g`)
- Terminal management keymaps (`<leader>t`)
- Test/spec file navigation
- Macro recording shortcuts
- Register management shortcuts

