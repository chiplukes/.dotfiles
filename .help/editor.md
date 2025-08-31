# VS Code & Vim Keybindings Cheat Sheet

## Intellisense & Suggestions
- `ctrl+space` — Trigger suggestions
- `ctrl+n` — Next suggestion (intellisense, quick open, code actions)
- `ctrl+p` — Previous suggestion (intellisense, quick open, code actions)
- `ctrl+y` — Accept selected suggestion or code action (intellisense, quick open, code actions; works in both normal and insert mode)
- `ctrl+n` — Next code action (quick fix)
- `ctrl+p` — Previous code action (quick fix)
- `ctrl+y` — Accept selected code action (quick fix)
- `ctrl+n` — Next item in quick open
- `ctrl+p` — Previous item in quick open
- `ctrl+y` — Accept selected quick open item

## Navigation
- `ctrl+h` — Previous tab
- `ctrl+l` — Next tab
- `ctrl+o` — Go to previous location
- `ctrl+i` — Go to next location
- `''` — Previous cursor location
- `g;` — Previous change
- `g,` — Next change

## Window Management
- `<leader>wv` — Split editor vertically
- `<leader>wc` — Close editor group
- `<leader>wf` — Toggle sidebar visibility
- `<leader>we` — Focus explorer

## Command Palette & Context
- `<leader>cp` — Show command palette
- `F1` — Show command palette
- `<leader>cm` — Show context menu

## Quick Open & Search
- `<leader>o` — Quick open
- `<leader>f` — Find in project

## Bookmarks
- `<leader>mm` — Toggle bookmark
- `<leader>ml` — List bookmarks
- `<leader>mn` — Next bookmark
- `<leader>mp` — Previous bookmark

## Gist
- `<leader>og` — Open gist

## Multicursor
- `<leader>ca` — Multi-cursor on all selected words

## Copilot & Inline Suggestions (Insert Mode)
- `ctrl+n` — Next copilot suggestion
- `ctrl+p` — Previous copilot suggestion
- `ctrl+y` — Accept copilot suggestion
- `ctrl+i` — Trigger copilot suggestion

## Copilot & Code Actions (Normal Mode)
- `<leader>y` — Accept copilot suggestion or code action
- `<ctrl+y>` — Accept copilot suggestion or code action

## Formatting
- `<leader>rf` — Format document (black for Python)
- `<leader>bs` — Format selection (black for Python, if enabled)

## EasyAlign & Easymotion
- `s` + 2 letters — Easymotion jump
- `ga` — Align-by-Regex (in visual mode)
- `vipga=` — Visual select paragraph, EasyAlign on `=`
- `vipga*<space>` — Visual select paragraph, EasyAlign all spaces
- `vipga1<ctrlx>regexp` — Visual select paragraph, EasyAlign first regexp

## Visual Mode
- `vic` — Visual block select in column
- `cic` — Visual block change in column
- `v/foo` — Visual select until word "foo"

## Paste & Yank
- `<leader>p` — Paste from 0 register (vim)
- `ytx` — Yank to x
- `ye` — Yank to end of word

## Block Operations
- `ctrl-v` — Visual block select
- `ctrl-v` (select block), yank, `ctrl-v` (select block), `ctrl-shift-v` — Block copy/paste

## Macros
- `q` + letter — Start recording macro
- `esc + q` — Stop recording macro
- `@` + letter — Play macro
- `@@` — Play most recent macro

## Miscellaneous
- `gh` — Show hover (same as mouse hover)
- `<leader>c a` — Multi-cursor on all selected words
- `<leader>p` — Paste from 0 register
- `<leader>y` — Accept copilot/code action (normal mode)
- `<ctrl+y>` — Accept copilot/code action (normal mode)
- `<leader>q` — Accept code action/quick fix (normal mode)