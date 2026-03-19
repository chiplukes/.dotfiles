from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ed.api.editor import EditorAPI


def setup(api: EditorAPI) -> None:
    options = api.options
    keymap = api.keymap
    lsp = api.lsp
    remember = getattr(api, "_remember_cmd", lambda fn: fn)
    plugin_manager = globals().get("plugins")

    # ── Options ───────────────────────────────────────────────────────────
    options.set("leader", " ")
    options.set("tabstop", 4)
    options.set("expandtab", True)
    options.set("scrolloff", 8)
    options.set("which_key_enabled", True)
    options.set("indentguides", "yes")
    options.set("clipboard", "unnamedplus")
    options.set("cursorblink", True)
    options.set("insertcursor", "bar")
    options.set("number", True)
    options.set("relativenumber", False)

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
    keymap.nmap("<leader>sf", "<Plug>PickerFindFiles", desc="Find files")
    keymap.nmap("<leader>sb", "<Plug>PickerFindBuffers", desc="Find buffers")
    keymap.nmap("<leader>sg", "<Plug>PickerLiveGrep", desc="Live grep")

    # ── Git ───────────────────────────────────────────────────────────────
    keymap.ngroup("g", "Go to")
    keymap.nmap("gn", "<Plug>GitsignsNextHunk", desc="Next git hunk")
    keymap.nmap("gp", "<Plug>GitsignsPrevHunk", desc="Prev git hunk")
    keymap.nmap("go", lambda: lsp.document_symbols(), desc="Document symbols")

    # ── Project/Session ───────────────────────────────────────────────────
    keymap.ngroup("<leader>p", "Project")
    keymap.nmap("<leader>ps", "<Plug>SessionSave", desc="Save session")
    keymap.nmap("<leader>prs", "<Plug>SessionRestore", desc="Restore session")
    keymap.nmap("<leader>pr", "<Plug>EditorPasteYank", desc="Paste yank register")

    # ── Code/LSP ──────────────────────────────────────────────────────────
    keymap.ngroup("<leader>c", "Code")
    keymap.nmap("<leader>ch", lambda: lsp.hover(), desc="Hover docs")
    keymap.nmap("<leader>ca", lambda: lsp.code_actions(), desc="Code actions")
    keymap.nmap("<leader>ci", lambda: lsp.toggle_inlay_hints(), desc="Toggle inlay hints")
    keymap.nmap("<leader>csd", lambda: lsp.document_symbols(), desc="Document symbols")
    keymap.nmap("<leader>csw", lambda: lsp.workspace_symbols(), desc="Workspace symbols")
    keymap.nmap("<leader>cd", lambda: lsp.definition(), desc="Go to definition")
    keymap.nmap("<leader>cgi", lambda: lsp.implementation(), desc="Go to implementation")
    keymap.nmap("<leader>cgt", lambda: lsp.type_definition(), desc="Go to type definition")
    keymap.nmap("<leader>cr", lambda: lsp.references(), desc="Find references")
    keymap.nmap("<leader>cn", lambda: lsp.rename(), desc="Rename symbol")
    keymap.nmap("<leader>cI", lambda: lsp.info(), desc="LSP info")
    keymap.nmap("<leader>cx", lambda: lsp.restart(), desc="Restart LSP")
    keymap.nmap("<leader>c.d", "<Plug>LspDiagDetail", desc="Diagnostic detail")
    keymap.nmap("<leader>cf", "<Plug>FormatterFormat", desc="Format buffer")
    keymap.imap("<C-k>", lambda: lsp.signature_help(), desc="Signature help")
    keymap.nmap("[d", remember(lambda: lsp.goto_prev_diag()), desc="Prev diagnostic")
    keymap.nmap("]d", remember(lambda: lsp.goto_next_diag()), desc="Next diagnostic")
    keymap.nmap("ge", remember(lambda: lsp.goto_next_diag()), desc="Next diagnostic")

    # ── File info ─────────────────────────────────────────────────────────
    keymap.ngroup("<leader>l", "Location/File")
    keymap.nmap("<leader>lf", "<Plug>EditorFileInfo", desc="File info")
    keymap.nmap("<leader>lfc", "<Plug>EditorCopyPath", desc="Copy full path")
    keymap.nmap("<leader>lfr", "<Plug>EditorCopyRel", desc="Copy relative path")

    # ── File ──────────────────────────────────────────────────────────────
    keymap.ngroup("<leader>f", "File")
    keymap.nmap("<leader>e", "<Plug>ExplorerToggle", desc="File explorer")
    keymap.nmap("<leader>fs", ":w<CR>", desc="Save file")
    keymap.nmap("<C-^>", "<Plug>EditorAltFile", desc="Alternate file")

    # ── Window Management (<leader>w) ─────────────────────────────────────
    keymap.ngroup("<leader>w", "Window")
    keymap.nmap("<leader>wv", ":vsplit<CR>", desc="Vertical split")
    keymap.nmap("<leader>ws", ":split<CR>", desc="Horizontal split")
    keymap.nmap("<leader>wc", ":close<CR>", desc="Close window")
    keymap.nmap("<leader>wf", ":only<CR>", desc="Fullscreen (close others)")
    keymap.nmap("<leader>wh", remember(lambda: api.focus_window("h")), desc="Window left / prev")
    keymap.nmap("<leader>wl", remember(lambda: api.focus_window("l")), desc="Window right / next")
    keymap.nmap("<leader>wj", remember(lambda: api.focus_window("j")), desc="Window down / next")
    keymap.nmap("<leader>wk", remember(lambda: api.focus_window("k")), desc="Window up / prev")

    # ── Window navigation (Alt + hjkl) ────────────────────────────────────
    keymap.nmap("<A-h>", lambda: api.focus_window("h"), desc="Window left / prev")
    keymap.nmap("<A-l>", lambda: api.focus_window("l"), desc="Window right / next")
    keymap.nmap("<A-j>", lambda: api.focus_window("j"), desc="Window down / next")
    keymap.nmap("<A-k>", lambda: api.focus_window("k"), desc="Window up / prev")

    # ── Commentary ────────────────────────────────────────────────────────
    keymap.vmap("gc", "<Plug>CommentaryVisual", desc="Toggle comments")

    # ── Show file modification in gutter ─────────────────────────────────
    options.set("session_additions_enabled", True)
    options.set("session_additions_sign_char", "+")
    options.set("session_additions_sign_color", "80,200,80")
    if plugin_manager is not None:
        plugin_manager.load("ed.plugins.session_additions")
        plugin_manager.load("ed.plugins.tabs_to_spaces")

    # Add servers that are not auto-detected here if needed.
    # Example:
    # lsp.register_server("sh", ["bash-language-server", "start"])
