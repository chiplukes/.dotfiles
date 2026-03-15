# Example init.py

# ── Options ──────────────────────────────────────────────────────────
options.set("leader", " ")       # Space as leader
options.set("tabstop", 4)
options.set("expandtab", True)
options.set("scrolloff", 8)
options.set("which_key_enabled", True)

# Add custom keybindings
keymap.nmap("<leader>w", ":w<CR>", desc="Save file")

# Load extra plugins
plugins.load("ed.plugins.lsp")


# ── Which-key groups ─────────────────────────────────────────────────
# Remove old default picker bindings before remapping
keymap.nunmap("<leader>ff")
keymap.nunmap("<leader>fb")
keymap.nunmap("<leader>fg")
keymap.nunmap("<leader>F")

# Search group
keymap.ngroup("<leader>s", "Search")
keymap.nmap("<leader>sf", "<Plug>PickerFindFiles",   desc="Find files")
keymap.nmap("<leader>sb", "<Plug>PickerFindBuffers", desc="Find buffers")
keymap.nmap("<leader>sg", "<Plug>PickerLiveGrep",    desc="Live grep")

# Git
keymap.ngroup("g", "Go to")
keymap.nmap("gn", "<Plug>GitsignsNextHunk", desc="Next git hunk")
keymap.nmap("gp", "<Plug>GitsignsPrevHunk", desc="Prev git hunk")

# Project/Session
keymap.ngroup("<leader>p", "Project")
keymap.nmap("<leader>ps", "<Plug>SessionSave",    desc="Save session")
keymap.nmap("<leader>pr", "<Plug>SessionRestore", desc="Restore session")

# Code
keymap.ngroup("<leader>c", "Code")
keymap.nmap("<leader>cf", "<Plug>FormatterFormat", desc="Format buffer")

keymap.nmap("<leader>e", "<Plug>ExplorerToggle", desc="File explorer")
keymap.nmap("<leader>w", ":w<CR>", desc="Save file")

# REPL (default: <leader>sl / sb)
# keymap.nmap("<leader>rl", "<Plug>ReplSendLine",  desc="Send line to REPL")
# keymap.nmap("<leader>rb", "<Plug>ReplSendBlock", desc="Send block to REPL")

# Commentary (default: gcc / gcj / gck / gc)
keymap.vmap("gc", "<Plug>CommentaryVisual", desc="Toggle comments on selection")

# ~/.config/ed/init.py


