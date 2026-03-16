# ── Options ───────────────────────────────────────────────────────────
options.set("leader", " ")
options.set("tabstop", 4)
options.set("expandtab", True)
options.set("scrolloff", 8)
options.set("which_key_enabled", True)
options.set("indentguides", "yes")
options.set("clipboard", "unnamedplus")

# ── LSP server ────────────────────────────────────────────────────────
lsp.register_server("python", ["ty", "server"])

# ── Repeat last command ───────────────────────────────────────────────
keymap.nmap("<leader><leader>", "<Plug>EditorRepeat", desc="Repeat last command")

# ── Search ────────────────────────────────────────────────────────────
keymap.nunmap("<leader>ff")
keymap.nunmap("<leader>fb")
keymap.nunmap("<leader>fg")
keymap.nunmap("<leader>F")
keymap.ngroup("<leader>s", "Search")
keymap.nmap("<leader>sf", "<Plug>PickerFindFiles",   desc="Find files")
keymap.nmap("<leader>sb", "<Plug>PickerFindBuffers", desc="Find buffers")
keymap.nmap("<leader>sg", "<Plug>PickerLiveGrep",    desc="Live grep")

# ── Git ───────────────────────────────────────────────────────────────
keymap.ngroup("g", "Go to")
keymap.nmap("gn", "<Plug>GitsignsNextHunk", desc="Next git hunk")
keymap.nmap("gp", "<Plug>GitsignsPrevHunk", desc="Prev git hunk")

# ── Project/Session ───────────────────────────────────────────────────
keymap.ngroup("<leader>p", "Project")
keymap.nmap("<leader>ps",  "<Plug>SessionSave",    desc="Save session")
keymap.nmap("<leader>prs", "<Plug>SessionRestore", desc="Restore session")
keymap.nmap("<leader>pr",  "<Plug>EditorPasteYank", desc="Paste yank register")

# ── Code/LSP ──────────────────────────────────────────────────────────
keymap.ngroup("<leader>c", "Code")
keymap.nmap("<leader>ch",  lambda: lsp.hover(),        desc="Hover docs")
keymap.nmap("<leader>cd",  lambda: lsp.definition(),   desc="Go to definition")
keymap.nmap("<leader>cr",  lambda: lsp.references(),   desc="Find references")
keymap.nmap("<leader>cn",  lambda: lsp.rename(),       desc="Rename symbol")
keymap.nmap("<leader>ci",  lambda: lsp.info(),         desc="LSP info")
keymap.nmap("<leader>cx",  lambda: lsp.restart(),      desc="Restart LSP")
keymap.nmap("<leader>c.d", "<Plug>LspDiagDetail",      desc="Diagnostic detail")
keymap.nmap("<leader>cf",  "<Plug>FormatterFormat",    desc="Format buffer")

# Diagnostic navigation — all repeatable with <leader><leader>
keymap.nmap("[d", remember(lambda: lsp.goto_prev_diag()), desc="Prev diagnostic")
keymap.nmap("]d", remember(lambda: lsp.goto_next_diag()), desc="Next diagnostic")
keymap.nmap("ge", remember(lambda: lsp.goto_next_diag()), desc="Next diagnostic")

# ── File info ─────────────────────────────────────────────────────────
keymap.ngroup("<leader>l", "Location/File")
keymap.nmap("<leader>lf",  "<Plug>EditorFileInfo", desc="File info")
keymap.nmap("<leader>lfc", "<Plug>EditorCopyPath", desc="Copy full path")
keymap.nmap("<leader>lfr", "<Plug>EditorCopyRel",  desc="Copy relative path")

# ── File ──────────────────────────────────────────────────────────────
keymap.ngroup("<leader>f", "File")
keymap.nmap("<leader>e",  "<Plug>ExplorerToggle", desc="File explorer")
keymap.nmap("<leader>fs", ":w<CR>",               desc="Save file")
keymap.nmap("<C-^>",      "<Plug>EditorAltFile",  desc="Alternate file")

# ── Window Management (<leader>w) ─────────────────────────────────────
keymap.ngroup("<leader>w", "Window")
keymap.nmap("<leader>wv", ":vsplit<CR>",  desc="Vertical split")
keymap.nmap("<leader>ws", ":split<CR>",   desc="Horizontal split")
keymap.nmap("<leader>wc", ":close<CR>",   desc="Close window")
keymap.nmap("<leader>wf", ":only<CR>",    desc="Fullscreen (close others)")
keymap.nmap("<leader>wh", remember(lambda: api.focus_window("h")), desc="Window left / prev")
keymap.nmap("<leader>wl", remember(lambda: api.focus_window("l")), desc="Window right / next")
keymap.nmap("<leader>wj", remember(lambda: api.focus_window("j")), desc="Window down / next")
keymap.nmap("<leader>wk", remember(lambda: api.focus_window("k")), desc="Window up / prev")

# ── Window navigation (Alt + hjkl) ────────────────────────────────────
# Moves directionally within splits; wraps to next/prev window at edges
keymap.nmap("<A-h>", lambda: api.focus_window("h"), desc="Window left / prev")
keymap.nmap("<A-l>", lambda: api.focus_window("l"), desc="Window right / next")
keymap.nmap("<A-j>", lambda: api.focus_window("j"), desc="Window down / next")
keymap.nmap("<A-k>", lambda: api.focus_window("k"), desc="Window up / prev")

# ── Commentary ────────────────────────────────────────────────────────
keymap.vmap("gc", "<Plug>CommentaryVisual", desc="Toggle comments")


# # Use a specific Python server (overrides auto-detect)
lsp.register_server("python", ["ty", "server"])
# # or basedpyright:
# # lsp.register_server("python", ["basedpyright", "--stdio"])

# # Add a server that isn't auto-detected (e.g. bash LSP)
# lsp.register_server("sh", ["bash-language-server", "start"])
# # Note: lsp is available directly in init.py as a sub-API on the api object. The flat namespace (keymap, options, etc.) doesn't expose lsp by default — use api.lsp or add it:

# # At the top of init.py, after other setup:
# lsp = api.lsp   # convenient alias

# # Or call it through the events system if you prefer not to alias:
# def setup(api):
#     api.lsp.register_server("python", ["ty", "server"])
#     api.keymap.nmap("<leader>li", lambda: api.lsp.info(), desc="LSP info")

# # The setup(api) function form is the cleanest — the loader calls it with the full API object after executing module-level code.



# ~/.config/ed/init.py


