# Neovim Keymaps Reference

**Generated:** 2025-10-30
**Purpose:** Organized keymap reference for easy lookup and future refactoring

---

## 🌟 VIP Keymaps (No Category Prefix)

These are frequently-used shortcuts that bypass category prefixes for quick access.

| Keymap | Description | File | Notes |
|--------|-------------|------|-------|
| `<leader>ff` | Find files in project | keymaps.lua | VS Code-style file search |
| `<leader>gc` | Toggle comment | (default) | Line/block commenting |
| `ge` | Go to next error | (default) | VS Code-style error navigation |
| `gh` | Hover info | keymaps.lua | Quick hover documentation |
| `go` | Go to outline/symbols | keymaps.lua | Document symbol outline |
| `K` | Hover documentation | lsp_config.lua | LSP hover info |
| `sj` | Flash jump (EasyMotion) | flash.lua | Quick cursor navigation |
| `<C-.>` | Quick fix | keymaps.lua | VS Code-style code action |
| `<Alt-h>` | Window/buffer left (with wrap) | keymaps.lua | Navigate left or previous tab |
| `<Alt-l>` | Window/buffer right (with wrap) | keymaps.lua | Navigate right or next tab |
| `<Alt-j>` | Window down | keymaps.lua | Navigate to lower window |
| `<Alt-k>` | Window up | keymaps.lua | Navigate to upper window |
| `<Esc>` | Clear search highlight | keymaps.lua | Clear search results |

---

## 📝 Code (`<leader>c`)

Code-related operations: LSP actions, refactoring, formatting, diagnostics.

### LSP Actions

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Actions | `a` | Code actions (enhanced) | lsp_config.lua | Context menu |
| Actions | `m` | Context menu | keymaps.lua | Alternative to `.` |
| Refactor | `pr` | Python refactor extract | lsp_config.lua | Python-specific |
| Imports | `pi` | Python add missing imports | lsp_config.lua | Python-specific |
| Imports | `oi` | Organize imports | lsp_config.lua | General import cleanup |

### Goto Navigation (`g`)

| Subcategory -g | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Goto | `r` | Go to references | lsp_config.lua | Find all references |
| Goto | `d` | Go to definition | lsp_config.lua | Jump to definition |
| Goto | `i` | Go to implementation | lsp_config.lua | Jump to implementation |
| Goto | `D` | Go to declaration | lsp_config.lua | Jump to declaration |
| Goto | `t` | Go to type definition | lsp_config.lua | Jump to type def |
| Goto | `a` | Code action at cursor | (default) | Quick action |
| Goto | `rn` | Rename symbol | (default) | LSP rename |

### Diagnostics (gd* prefix)

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Diagnostic | `gdn` | Go to next diagnostic | lsp_config.lua | Next issue |
| Diagnostic | `gdp` | Go to previous diagnostic | lsp_config.lua | Previous issue |
| Diagnostic | `gdd` | Diagnostic details | lsp_config.lua | Show full details |
| Diagnostic | `]d` | Next diagnostic | (default) | Alternative binding |
| Diagnostic | `[d` | Previous diagnostic | (default) | Alternative binding |
| Diagnostic | `e` | Show error messages | (default) | Diagnostic float |
| Diagnostic | `q` | Diagnostic quickfix | (default) | Quickfix list |
| Diagnostic | `u` | Hide diagnostics | keymaps.lua | Undo/hide suggestions |

### Symbols & Search

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Symbols | `ss` | Search document symbols | lsp_config.lua | Current file symbols |
| Symbols | `sS` | Search workspace symbols | lsp_config.lua | Project-wide symbols |
| Symbols | `gO` | Open document symbols | lsp_config.lua | Symbol outline |
| Symbols | `gW` | Open workspace symbols | lsp_config.lua | Workspace outline |

### Formatting

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Format | `fb` | Format buffer | lsp_config.lua | Format entire file |
| Format | `rf` (n) | Format document | keymaps.lua | Recode format |
| Format | `rf` (v) | Format selection | keymaps.lua | Format visual selection |

### Workspace

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Workspace | `wa` | Add folder | (default) | Add to workspace |
| Workspace | `wr` | Remove folder | (default) | Remove from workspace |
| Workspace | `wl` | List folders | lsp_config.lua | Show workspace folders |

### Python-Specific

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Python | `pd` | Add docstring | autocmds.lua | Generate docstring |

---

## 🐛 Debug (`d`)

Debugging operations and breakpoint management.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Breakpoint | `b` | Toggle breakpoint | (lazy) | Toggle BP at line |
| Breakpoint | `B` | Set breakpoint | (lazy) | Set conditional BP |
| Control | `<F5>` | Start/Continue | (lazy) | Begin/resume debugging |
| Control | `<F1>` | Step into | (lazy) | Step into function |
| Control | `<F2>` | Step over | (lazy) | Step over line |
| Control | `<F3>` | Step out | (lazy) | Step out of function |

---

## 🔍 Search (`<leader>s`)

File search, grep, and fuzzy finding operations.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Files | `sf` | Search files | snacks.lua | Find by filename |
| Files | `s.` | Recent files | snacks.lua | Recently opened |
| Files | `sn` | Neovim config files | snacks.lua | Search config dir |
| Content | `sg` | Search by grep | snacks.lua | Live grep content |
| Content | `sw` | Search current word | snacks.lua | Grep word under cursor |
| Content | `/` | Search in buffer | snacks.lua | Fuzzy search current file |
| Content | `s/` | Search in open files | snacks.lua | Search across buffers |
| Smart | `ss` | Smart search | snacks.lua | Context-aware search |
| Other | `sk` | Search keymaps | snacks.lua | Find keybindings |
| Other | `sh` | Search help | snacks.lua | Neovim help tags |
| Other | `sd` | Search diagnostics | snacks.lua | Find diagnostics |
| Other | `sr` | Resume search | snacks.lua | Resume last picker |
| Other | `<leader><leader>` | Find buffers | snacks.lua | Open buffer list |

---

## 📌 Markers/Bookmarks (`<leader>m`)

Bookmark and marker management.

### Basic Markers

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Basic | `mm` | Toggle bookmark | keymaps.lua | Mark current line |
| Basic | `mn` | Next bookmark | keymaps.lua | Jump to next |
| Basic | `mp` | Previous bookmark | keymaps.lua | Jump to previous |
| Basic | `ma` | Add marker | marker-groups.nvim | Add with description |
| Basic | `ml` | List markers | marker-groups.nvim | Show buffer markers |
| Basic | `mi` | Show marker info | marker-groups.nvim | Details at cursor |
| Basic | `md` | Delete marker | marker-groups.nvim | Remove at cursor |
| Basic | `me` | Edit marker | marker-groups.nvim | Modify marker |
| Basic | `mv` | Toggle marker viewer | marker-groups.nvim | Drawer view |

### Marker Groups

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Groups | `mgc` | Create group | marker-groups.nvim | New marker group |
| Groups | `mgs` | Select group | marker-groups.nvim | Switch active group |
| Groups | `mgl` | List groups | marker-groups.nvim | Show all groups |
| Groups | `mgr` | Rename group | marker-groups.nvim | Rename active group |
| Groups | `mgd` | Delete group | marker-groups.nvim | Remove group |
| Groups | `mgi` | Group info | marker-groups.nvim | Show group details |
| Groups | `mgb` | Create from branch | marker-groups.nvim | Git branch group |

---

## 🪟 Window Management (`<leader>w`)

Window splitting, navigation, and layout management.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Split | `wv` | Split vertical | keymaps.lua | Vertical split |
| Split | `wc` | Close window | keymaps.lua | Close current |
| Split | `wf` | Fullscreen | keymaps.lua | Close other windows |
| Navigation | `<M-h>` | Left/prev buffer/tab | keymaps.lua | With wrap-around |
| Navigation | `<M-l>` | Right/next buffer/tab | keymaps.lua | With wrap-around |
| Navigation | `<M-k>` | Window up | keymaps.lua | Move to upper |
| Navigation | `<M-j>` | Window down | keymaps.lua | Move to lower |
| Other | `we` | Explorer (netrw) | keymaps.lua | File browser |

---

## 📂 Explorer/Files (`<leader>e`)

File exploration and project navigation.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Explorer | `se` | Show explorer | snacks.lua | File tree view |
| Explorer | `of` | Open file picker | keymaps.lua | Quick file open |
| Explorer | `we` | Window explorer | keymaps.lua | Netrw explorer |

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
| Inspect | `li` | Inspect word | learn.lua | Inspect value at cursor |
| Info | `lb` | Buffer info | learn.lua | Show buffer details |
| Info | `lw` | Window info | learn.lua | Show window details |
| Info | `ll` | LSP clients | learn.lua | Active LSP servers |
| Info | `lp` | Plugins | learn.lua | Loaded plugins |
| Info | `lk` | Keymaps | learn.lua | Show keymaps for mode |
| Info | `lh` | Highlight groups | learn.lua | Treesitter highlights |
| Info | `lo` | Options | learn.lua | Vim option values |
| Info | `?` | Learning dashboard | learn.lua | Open help dashboard |

### Code Execution

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Execute | `lx` (n) | Execute Lua line | learn.lua | Run current line |
| Execute | `lx` (v) | Execute Lua selection | learn.lua | Run selected code |
| Execute | `px` (n) | Execute Python line | learn.lua | Run current line |
| Execute | `px` (v) | Execute Python selection | learn.lua | Run selected code |
| Module | `lr` | Reload module | learn.lua | Hot reload config |

---

## 📋 Sessions (`<leader>q`)

Session management and persistence.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Session | `qs` | Restore session | persistence.lua | Load saved session |
| Session | `ql` | Restore last session | persistence.lua | Last session |
| Session | `qd` | Don't save session | persistence.lua | Skip auto-save |

---

## ✨ Editor Features (`<leader>o`)

Other editor operations.

| Subcategory | Keymap | Description | File | Notes |
|-------------|--------|-------------|------|-------|
| Command | `cp` | Command palette | keymaps.lua | VS Code-style palette |
| Misc | `gg` | Lazygit | snacks.lua | Git interface |
| Misc | `pr` | Paste from yank | keymaps.lua | Paste register 0 |


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

### Conflicts to Resolve
- `<leader>fb` appears in both Code (format) and as standalone
- Multiple format keymaps need consolidation
- Consider moving `<leader>pr` (Python refactor) under a Python submenu

---

## 🔍 Quick Reference by Function

**File Operations:** `<leader>ff`, `<leader>sf`, `<leader>se`, `<leader>of`
**Search Content:** `<leader>sg`, `<leader>sw`, `<leader>/`
**Code Actions:** `<C-.>`, `<leader>.`, `<leader>cm`, `<leader>ca`
**Navigate Code:** `grd`, `grr`, `gri`, `grt`, `grD`, `grn`
**Diagnostics:** `gdn`, `gdp`, `gdd`, `[d`, `]d`, `<leader>e`
**Format Code:** `<leader>cf`, `<leader>fb`, `<leader>rf`
**Bookmarks:** `<leader>mm`, `<leader>mn`, `<leader>mp`
**Sessions:** `<leader>qs`, `<leader>ql`, `<leader>qd`
**Window Nav:** `<M-h>`, `<M-l>`, `<M-j>`, `<M-k>`
**Quick Jump:** `sj`, `S`, `f/F/t/T`
