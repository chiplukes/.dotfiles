# Neovim Keymaps Reference

**Generated:** 2025-12-24
**Purpose:** Organized keymap reference for easy lookup and future refactoring

**Legend:** VS Code column shows mapping status
- ✅ = Mapped (same or similar keymap)
- ⚡ = Mapped with different keymap
- 🔧 = Not mapped, but VS Code command exists (add to settings)
- ❌ = No VS Code equivalent

---

## 🌟 VIP Keymaps (No Category Prefix)

These are frequently-used shortcuts that bypass category prefixes for quick access.

| Keymap | Description | File | Repeatable | Notes | VS Code |
|--------|-------------|------|------------|-------|---------|
| `<leader><leader>` | Repeat last command | keymaps.lua | n | Repeat previous command | ✅ (extension) |
| `gc` | Toggle comment | (mini.comment) | n | Line/block commenting | ✅ (built-in) |
| `ge` | Next error | keymaps.lua | y | VS Code-style error nav | ✅ `editor.action.marker.nextInFiles` |
| `go` | Outline | keymaps.lua | n | Document symbols | ✅ `workbench.action.gotoSymbol` |
| `K` | Hover docs | lsp_config.lua | n | LSP hover info | ⚡ `gh` → `editor.action.showHover` |
| `s` | Flash jump | flash.lua | n | EasyMotion-style nav | ✅ EasyMotion `<leader><leader>2s` |
| `<Alt-h>` | Window/tab left | keymaps.lua | n | Navigate left with wrap | ❌ |
| `<Alt-l>` | Window/tab right | keymaps.lua | n | Navigate right with wrap | ❌ |
| `<Alt-j>` | Window down | keymaps.lua | n | Navigate to lower window | ❌ |
| `<Alt-k>` | Window up | keymaps.lua | n | Navigate to upper window | ❌ |
| `<leader>pr` | Paste yank register | keymaps.lua | y | Paste last yank | ⚡ `<leader>p` → `"0P` |
| `<leader>e` | Explorer | keymaps.lua | n | File tree view | ⚡ `<leader>we` → `workbench.view.explorer` |
| `<leader>g` | Lazygit | keymaps.lua | n | Git interface | ❌ |

---

## 📝 Code (`<leader>c`)

Code-related operations: LSP actions, refactoring, formatting, diagnostics.

### Direct Code Actions

| Keymap | Mode | Description | File | Notes | VS Code |
|--------|------|-------------|------|-------|---------||
| `<leader>cr` | n | Rename | keymaps.lua | LSP rename across project | 🔧 `editor.action.rename` |
| `<leader>ca` | n | Code action | keymaps.lua | Context-sensitive fixes | 🔧 `editor.action.quickFix` |
| `<leader>ci` | n | Toggle inlay hints | lsp_config.lua | Show/hide type hints | 🔧 `editor.inlayHints.toggle` |

### Python Specific (`<leader>cp`)

| Keymap | Mode | Description | File | Notes | VS Code |
|--------|------|-------------|------|-------|---------||
| `<leader>cpd` | n | Docstring | autocmds.lua | Generate Python docstring | ❌ |

### Goto Navigation (`<leader>cg`)

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>cgr` | References | lsp_config.lua | Find all references | 🔧 `editor.action.goToReferences` |
| `<leader>cgd` | Definition | lsp_config.lua | Jump to definition | ✅ `gd` built-in |
| `<leader>cgi` | Implementation | lsp_config.lua | Jump to implementation | 🔧 `editor.action.goToImplementation` |
| `<leader>cgD` | Declaration | lsp_config.lua | Jump to declaration | 🔧 `editor.action.revealDeclaration` |
| `<leader>cgt` | Type definition | lsp_config.lua | Jump to type def | 🔧 `editor.action.goToTypeDefinition` |

### Diagnostics (`<leader>c.`)

| Keymap | Description | File | Repeatable | Notes | VS Code |
|--------|-------------|------|------------|-------|---------||
| `<leader>c.n` | Next | keymaps.lua | y | Next diagnostic | ⚡ `ge` → `editor.action.marker.nextInFiles` |
| `<leader>c.p` | Prev | keymaps.lua | y | Previous diagnostic | 🔧 `editor.action.marker.prevInFiles` |
| `<leader>c.d` | Details | keymaps.lua | n | Show full details | 🔧 `editor.action.showHover` |
| `<leader>c.e` | Errors list | keymaps.lua | n | Error quickfix | 🔧 `workbench.actions.view.problems` |
| `<leader>c.q` | Quickfix | keymaps.lua | n | All diagnostics | 🔧 `editor.action.quickFix` |
| `<leader>c.v` | Toggle virtual text | keymaps.lua | n | Show/hide inline | ❌ (no toggle, use settings) |
| `<leader>c.f` | Fix line | keymaps.lua | n | Ruff fix at cursor | 🔧 `editor.action.autoFix` |

### Symbols (`<leader>cs`)

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>csd` | Doc symbols | lsp_config.lua | Current file symbols | ⚡ `go` → `workbench.action.gotoSymbol` |
| `<leader>csw` | Workspace symbols | lsp_config.lua | Project-wide symbols | 🔧 `workbench.action.showAllSymbols` |

### Formatting (`<leader>cf`)

| Keymap | Mode | Description | File | Notes | VS Code |
|--------|------|-------------|------|-------|---------||
| `<leader>cfb` | n | Format buffer | keymaps.lua | Format entire file | ⚡ `<leader>rf` (visual) → `editor.action.formatDocument` |
| `<leader>cfs` | v | Format selection | keymaps.lua | Format visual selection | 🔧 `editor.action.formatSelection` |

### Debug (`<leader>cd`)

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>cdb` | Breakpoint | keymaps.lua | Toggle breakpoint | 🔧 `editor.debug.action.toggleBreakpoint` |
| `<F5>` | Start/Continue | (lazy) | Begin/resume debugging | ✅ (built-in) |
| `<F1>` | Step into | (lazy) | Step into function | ⚡ `F11` built-in |
| `<F2>` | Step over | (lazy) | Step over line | ⚡ `F10` built-in |
| `<F3>` | Step out | (lazy) | Step out of function | ⚡ `Shift+F11` built-in |

---

## 🔍 Search (`<leader>s`)

File search, grep, and fuzzy finding operations.

**Picker Actions (available in all search pickers):**
- `<CR>` - Open file (default)
- `w` - Window picker (select location)
- `t` - Open in new tab
- `v` - Open in vertical split
- `h` - Open in horizontal split

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>sf` | Files | keymaps.lua | Find by filename | ⚡ `<leader>o` → `workbench.action.quickOpen` |
| `<leader>sr` | Recent | keymaps.lua | Recently opened | 🔧 `workbench.action.openRecent` |
| `<leader>sc` | Config | keymaps.lua | Neovim config dir | ❌ (Neovim-specific) |
| `<leader>sg` | Grep | keymaps.lua | Live grep content | 🔧 `workbench.action.findInFiles` |
| `<leader>sw` | Word | keymaps.lua | Grep word at cursor | ⚡ `<leader>f` → `extension.searchUnderCursor` |
| `<leader>s/` | Buffer lines | keymaps.lua | Fuzzy in current file | 🔧 `actions.find` (Ctrl+F) |
| `<leader>sof` | Open files | keymaps.lua | Search across buffers | 🔧 `workbench.action.showAllEditors` |
| `<leader>ss` | Smart | keymaps.lua | Context-aware search | ❌ (Neovim-specific) |
| `<leader>sk` | Keymaps | keymaps.lua | Find keybindings | 🔧 `workbench.action.openGlobalKeybindings` |
| `<leader>sh` | Help | keymaps.lua | Neovim help tags | ❌ (Neovim-specific) |
| `<leader>sd` | Diagnostics | keymaps.lua | Find diagnostics | 🔧 `workbench.actions.view.problems` |
| `<leader>sb` | Buffers | keymaps.lua | Open buffer list | 🔧 `workbench.action.showAllEditors` |
| `<leader>sp` | Commands | keymaps.lua | Command palette | ⚡ `<leader>cp` → `workbench.action.showCommands` |

---

## 📌 Markers (`<leader>m`)

Marker and bookmark management using marker-groups.nvim.

### Basic Markers

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>ma` | Add | keymaps.lua | Add new marker | ⚡ `<leader>mm` → `bookmarks.toggle` |
| `<leader>md` | Remove | keymaps.lua | Delete marker at cursor | ⚡ `<leader>mm` → `bookmarks.toggle` |
| `<leader>mv` | Viewer | keymaps.lua | Show/hide marker drawer | ⚡ `<leader>ml` → `bookmarks.list` |

### Marker Groups (`<leader>mg`)

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>mgc` | Create | keymaps.lua | New marker group | ❌ (bookmarks simpler) |
| `<leader>mgs` | Select | keymaps.lua | Switch active group | ❌ (bookmarks simpler) |
| `<leader>mgr` | Rename | keymaps.lua | Rename active group | ❌ (bookmarks simpler) |
| `<leader>mgd` | Delete | keymaps.lua | Remove group | ❌ (bookmarks simpler) |
| `<leader>mgb` | From branch | keymaps.lua | Create group from git branch | ❌ (bookmarks simpler) |

---

## 🪟 Window (`<leader>w`)

Window splitting, navigation, and layout management.

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>wv` | Vertical split | keymaps.lua | Split vertical | ✅ `workbench.action.splitEditorRight` |
| `<leader>wc` | Close | keymaps.lua | Close current | ✅ `workbench.action.closeGroup` |
| `<leader>wf` | Fullscreen | keymaps.lua | Close other windows | ✅ `workbench.action.toggleSidebarVisibility` |
| `<leader>we` | Expand toggle | keymaps.lua | Toggle 3/4 width | ⚡ `workbench.view.explorer` (different) |
| `<leader>wt` | To new tab | keymaps.lua | Move to new tab | 🔧 `workbench.action.moveEditorToNewWindow` |

---

## 📂 Explorer (`<leader>e`)

File exploration and project navigation.

**Explorer Actions:**
- `l` - Open file / expand dir
- `h` - Close directory
- `a` - Add file
- `d` - Delete
- `r` - Rename
- `c` - Copy
- `m` - Move
- `y` - Yank path
- `p` - Paste
- `w` - Window picker
- `t` - Open in new tab
- `v` - Open in vertical split

---

## 💬 AI/Copilot

AI assistance and code suggestions (insert mode).

| Mode | Keymap | Description | File | Notes | VS Code |
|------|--------|-------------|------|-------|---------||
| i | `<Tab>` | Accept suggestion | copilot.lua | Accept or fallback to tab | ⚡ `<C-y>` → `editor.action.inlineSuggest.commit` |
| i | `<C-]>` | Next suggestion | copilot.lua | Cycle forward | ⚡ `<C-n>` → `editor.action.inlineSuggest.showNext` |
| i | `<C-[>` | Prev suggestion | copilot.lua | Cycle backward | ⚡ `<C-p>` → `editor.action.inlineSuggest.showPrevious` |
| i | `<C-\>` | Dismiss | copilot.lua | Hide suggestion | ❌ |
| i | `<C-Right>` | Accept word | copilot.lua | Accept next word | ❌ |
| i | `<C-CR>` | Show panel | copilot.lua | Full suggestions list | ❌ |
| i | - | Trigger suggestion | - | - | ✅ `<C-i>` → `editor.action.inlineSuggest.trigger` |

---

## 🎓 Learning (`<leader>l`)

Learning utilities and config debugging tools.

### Inspection

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>li` | Inspect | keymaps.lua | Inspect value at cursor | ❌ (Neovim-specific) |
| `<leader>lb` | Buffer | keymaps.lua | Show buffer details | ❌ (Neovim-specific) |
| `<leader>lw` | Window | keymaps.lua | Show window details | ❌ (Neovim-specific) |
| `<leader>ll` | LSP | keymaps.lua | Active LSP servers | ❌ (Neovim-specific) |
| `<leader>lp` | Plugins | keymaps.lua | Loaded plugins | 🔧 `workbench.extensions.action.listExtensions` |
| `<leader>lk` | Keymaps | keymaps.lua | Show keymaps for mode | 🔧 `workbench.action.openGlobalKeybindings` |
| `<leader>lh` | Highlights | keymaps.lua | Treesitter highlights | ❌ (Neovim-specific) |
| `<leader>lo` | Options | keymaps.lua | Vim option values | 🔧 `workbench.action.openSettings` |
| `<leader>l?` | Dashboard | keymaps.lua | Open help dashboard | 🔧 `workbench.action.showWelcomePage` |
| `<leader>lhr` | Reload | keymaps.lua | Hot reload config | 🔧 `workbench.action.reloadWindow` |

### File Info (`<leader>lf`)

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>lf` | File info | keymaps.lua | Show file details | 🔧 `workbench.action.showActiveFileInExplorer` |
| `<leader>lfc` | Copy full path | keymaps.lua | Copy to clipboard | 🔧 `copyFilePath` |
| `<leader>lfr` | Copy relative | keymaps.lua | Copy relative path | 🔧 `copyRelativeFilePath` |

### Code Execution (`<leader>lx`)

| Keymap | Mode | Description | File | Notes | VS Code |
|--------|------|-------------|------|-------|---------||
| `<leader>lxl` | n | Lua line | keymaps.lua | Run current line | ❌ (Lua-specific) |
| `<leader>lxl` | v | Lua selection | keymaps.lua | Run selected code | ❌ (Lua-specific) |
| `<leader>lxp` | n | Python line | keymaps.lua | Run current line | 🔧 `python.execInTerminal` |
| `<leader>lxp` | v | Python selection | keymaps.lua | Run selected code | 🔧 `python.execSelectionInTerminal` |

---

## 📋 Sessions (`<leader>q`)

Session management and persistence.

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>qs` | Switch | keymaps.lua | Pick session to restore | ❌ |
| `<leader>qd` | Don't save | keymaps.lua | Skip auto-save | ❌ |

---

## ✨ Git (`<leader>g`)

Git operations.

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<leader>g` | Lazygit | keymaps.lua | Git interface | ❌ |

---

## 🎯 Motion & Navigation

Enhanced movement and text object operations.

### Flash (EasyMotion-style)

| Mode | Keymap | Description | File | Notes | VS Code |
|------|--------|-------------|------|-------|---------||
| n/x/o | `s` | Flash jump | flash.lua | Jump to visible text | ✅ EasyMotion `<leader><leader>2s` |
| n/x/o | `f/F/t/T` | Enhanced char motion | flash.lua | Flash-enhanced | ❌ (standard vim f/F/t/T) |

### Text Objects (mini.ai)

Mini.ai extends Vim's built-in text objects. Use with operators like `d`, `c`, `y`, `v`.

- `a<char>` = Around (e.g., `da"` deletes around quotes)
- `i<char>` = Inside (e.g., `ci'` changes inside quotes)

**Supported:** `(`, `)`, `{`, `}`, `[`, `]`, `<`, `>`, `"`, `'`, `` ` ``

**Examples:**
- `diw` = delete inside word
- `da(` = delete around parentheses
- `cit` = change inside tags
- `yi"` = yank inside double quotes
- `va{` = visual select around braces

### Alignment (mini.align)

| Mode | Keymap | Description | File | Notes | VS Code |
|------|--------|-------------|------|-------|---------||
| v | `ga` | Align by char | utilities.lua | Align on character | ✅ `align.by.regex` |
| v | `gA` | Align by regex | utilities.lua | Advanced alignment | ❌ |

---

## 🔧 Snippets (LuaSnip)

| Mode | Keymap | Description | File | Notes | VS Code |
|------|--------|-------------|------|-------|---------||
| i/s | `<Tab>` | Expand/jump next | luasnip.lua | Navigate forward | ✅ (built-in) |
| i/s | `<S-Tab>` | Jump prev | luasnip.lua | Navigate backward | ✅ (built-in) |
| i | `<C-E>` | Choose option | luasnip.lua | Choice node | ❌ |

---

## 💡 Completion (blink.cmp)

Command mode completion.

| Mode | Keymap | Description | File | Notes | VS Code |
|------|--------|-------------|------|-------|---------||
| c | `<Tab>` | Next | blink.cmp | Navigate down | ✅ (built-in) |
| c | `<S-Tab>` | Prev | blink.cmp | Navigate up | ✅ (built-in) |
| c | `<C-Space>` | Show | blink.cmp | Trigger menu | ✅ (built-in) |
| c | `<C-Y>` | Accept | blink.cmp | Confirm | ✅ (built-in) |
| c | `<C-E>` | Cancel | blink.cmp | Close menu | ✅ (built-in) |
| c | `<C-N>/<C-P>` | Navigate | blink.cmp | Up/Down | ✅ (built-in) |

---

## 🔤 Insert Mode

| Keymap | Description | File | Notes | VS Code |
|--------|-------------|------|-------|---------||
| `<C-K>` | Signature help | lsp_config.lua | Show function signature | ❌ |
| `<C-U>` | Delete to start | (default) | With undo break | ✅ (built-in) |
| `<C-W>` | Delete word | (default) | With undo break | ✅ (built-in) |
| `<Esc>` | Exit insert | keymaps.lua | Mapped to `<C-c>` | ✅ (built-in) |

---

## 📝 Notes & TODOs

### VS Code-Only Keymaps (Not in Neovim)

These keymaps exist in your VS Code settings but don't have Neovim equivalents:

| Keymap | Mode | Description | Command |
|--------|------|-------------|---------|
| `<leader>og` | n | Open Gist | `extension.gist.openFavorite` |
| `<leader>cm` | n | Context menu | `editor.action.showContextMenu` |
| `<leader>y` | n | Accept suggestions | Various accept commands |
| `<leader>u` | n | Hide suggestions | Various hide commands |
| `<leader>mm` | n | Toggle bookmark | `bookmarks.toggle` |
| `<leader>ml` | n | List bookmarks | `bookmarks.list` |
| `<leader>mn` | n | Next bookmark | `bookmarks.jumpToNext` |
| `<leader>mp` | n | Prev bookmark | `bookmarks.jumpToPrevious` |

### Coverage Summary

**Legend:** ✅ Mapped | ⚡ Different key | 🔧 Available (not mapped) | ❌ No equivalent

| Category | Total | ✅/⚡ Mapped | 🔧 Available | ❌ None |
|----------|-------|-------------|--------------|---------|
| VIP Keymaps | 13 | 9 | 4 | 0 |
| Code Actions | 25 | 8 | 15 | 2 |
| Search | 13 | 4 | 6 | 3 |
| Markers | 8 | 3 | 0 | 5 |
| Window | 5 | 4 | 1 | 0 |
| AI/Copilot | 7 | 4 | 0 | 3 |
| Learning | 17 | 0 | 9 | 8 |
| Sessions | 2 | 0 | 0 | 2 |
| Git | 1 | 0 | 1 | 0 |
| Motion/Alignment | 4 | 2 | 0 | 2 |
| **Overall** | **~95** | **~34** | **~36** | **~25** |

**Key Insight:** ~74% of your Neovim keymaps have VS Code equivalents! Only ~26% are truly Neovim-specific (learning/debug introspection, Lua execution, sessions).

### Recommended Mappings to Add

High-value keymaps you should add to your VS Code settings:

```json
// Add to vim.normalModeKeyBindingsNonRecursive:
{"before": ["<leader>", "c", "r"], "commands": ["editor.action.rename"]},
{"before": ["<leader>", "c", "a"], "commands": ["editor.action.quickFix"]},
{"before": ["<leader>", "c", "g", "r"], "commands": ["editor.action.goToReferences"]},
{"before": ["<leader>", "c", "g", "i"], "commands": ["editor.action.goToImplementation"]},
{"before": ["<leader>", "s", "r"], "commands": ["workbench.action.openRecent"]},
{"before": ["<leader>", "s", "g"], "commands": ["workbench.action.findInFiles"]},
{"before": ["<leader>", "s", "b"], "commands": ["workbench.action.showAllEditors"]},
{"before": ["<leader>", "c", "s", "w"], "commands": ["workbench.action.showAllSymbols"]},
{"before": ["<leader>", "c", "d", "b"], "commands": ["editor.debug.action.toggleBreakpoint"]},
{"before": ["<Alt-h>"], "commands": ["workbench.action.focusLeftGroup"]},
{"before": ["<Alt-l>"], "commands": ["workbench.action.focusRightGroup"]},
{"before": ["<Alt-j>"], "commands": ["workbench.action.focusBelowGroup"]},
{"before": ["<Alt-k>"], "commands": ["workbench.action.focusAboveGroup"]},
```

### Future Considerations
- Terminal management keymaps (`<leader>t`)
- Test/spec file navigation
- Macro recording shortcuts
- Register management shortcuts
