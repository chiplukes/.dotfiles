from __future__ import annotations

from typing import TYPE_CHECKING

from ed.core.style import Style
from ed.syntax.themes import Theme, register_theme

if TYPE_CHECKING:
    from ed.api.editor import EditorAPI


def _register_vscode_dark_modern_theme() -> None:
    groups = {
        "keyword": Style(fg="#C586C0"),
        "keyword.control": Style(fg="#569CD6"),
        "keyword.conditional": Style(fg="#569CD6"),
        "keyword.return": Style(fg="#C586C0"),
        "keyword.function": Style(fg="#C586C0"),
        "keyword.operator": Style(fg="#D4D4D4"),
        "keyword.import": Style(fg="#C586C0"),
        "keyword.repeat": Style(fg="#569CD6"),
        "keyword.exception": Style(fg="#569CD6"),
        "string": Style(fg="#CE9178"),
        "string.escape": Style(fg="#D69D85"),
        "string.special": Style(fg="#CE9178"),
        "comment": Style(fg="#6A9955"),
        "function": Style(fg="#DCDCAA"),
        "function.call": Style(fg="#DCDCAA"),
        "function.builtin": Style(fg="#DCDCAA"),
        "function.macro": Style(fg="#F0F000"),
        "type": Style(fg="#569CD6"),
        "type.builtin": Style(fg="#569CD6"),
        "type.definition": Style(fg="#569CD6"),
        "variable": Style(fg="#D4D4D4"),
        "variable.builtin": Style(fg="#569CD6"),
        "variable.parameter": Style(fg="#9CDCFE"),
        "constant": Style(fg="#6A9955"),
        "constant.builtin": Style(fg="#6A9955"),
        "constant.macro": Style(fg="#F0F000"),
        "operator": Style(fg="#D4D4D4"),
        "number": Style(fg="#6A9955"),
        "float": Style(fg="#6A9955"),
        "boolean": Style(fg="#569CD6"),
        "punctuation": Style(fg="#D4D4D4"),
        "punctuation.bracket": Style(fg="#C586C0"),
        "punctuation.delimiter": Style(fg="#D4D4D4"),
        "punctuation.special": Style(fg="#D4D4D4"),
        "label": Style(fg="#D4D4D4"),
        "namespace": Style(fg="#F0F000"),
        "attribute": Style(fg="#9CDCFE"),
        "tag": Style(fg="#569CD6"),
        "error": Style(fg="#F44747"),
        "text": Style(fg="#D4D4D4"),
        "text.title": Style(fg="#DCDCAA"),
        "text.strong": Style(fg="#D4D4D4", attrs=1),
        "text.emphasis": Style(fg="#D4D4D4"),
        "text.literal": Style(fg="#CE9178"),
        "text.uri": Style(fg="#569CD6"),
        "sidebar": Style(bg="#252526"),
        "sidebar.header.active": Style(fg="#FFFFFF", bg="#50648C", attrs=1),
        "sidebar.header.inactive": Style(fg="#D2D2D2", bg="#282C34"),
        "embedded": Style(fg="#D4D4D4"),
        "property": Style(fg="#9CDCFE"),
        "field": Style(fg="#9CDCFE"),
        "constructor": Style(fg="#F0F000"),
        "module": Style(fg="#4EC9B0"),
        "module.instance": Style(fg="#DCDCAA"),
        "parameter": Style(fg="#9CDCFE"),
        "decorator": Style(fg="#DCDCAA"),
        "annotation": Style(fg="#DCDCAA"),
    }
    register_theme(
        "vscode_dark_modern",
        Theme(
            name="vscode_dark_modern",
            groups=groups,
            default_fg="#D4D4D4",
            default_bg="#1F1F1F",
        ),
    )


def setup(api: EditorAPI) -> None:
    plugin_manager = globals().get("plugins")

    if plugin_manager is not None:
        plugin_manager.load("ed.plugins.guess_indent")
        plugin_manager.load("ed.plugins.todo")
        plugin_manager.load("ed.plugins.gitsigns")
        plugin_manager.load("ed.plugins.picker")
        plugin_manager.load("ed.plugins.autopairs")
        plugin_manager.load("ed.plugins.commentary")
        plugin_manager.load("ed.plugins.surround")
        plugin_manager.load("ed.plugins.align")
        plugin_manager.load("ed.plugins.formatter")
        plugin_manager.load("ed.plugins.which_key")
        plugin_manager.load("ed.plugins.session")
        plugin_manager.load("ed.plugins.explorer")
        plugin_manager.load("ed.plugins.diagnostics_panel")
        plugin_manager.load("ed.plugins.outline")
        plugin_manager.load("ed.plugins.references_panel")
        plugin_manager.load("ed.plugins.workspace_symbols")
        plugin_manager.load("ed.plugins.repl")
        plugin_manager.load("ed.plugins.dashboard")
        plugin_manager.load("ed.plugins.editorconfig")
        plugin_manager.load("ed.plugins.lsp")
        plugin_manager.load("ed.plugins.editor_utils")
        plugin_manager.load("ed.plugins.flash")

    _register_vscode_dark_modern_theme()

    options = api.options
    keymap = api.keymap
    lsp = api.lsp
    remember = getattr(api, "_remember_cmd", lambda fn: fn)

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
    api._editor_state.active_theme = "vscode_dark_modern"

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
    keymap.nmap("<leader>sr", "<Plug>PickerRecentFiles", desc="Recent files")
    keymap.nmap("<leader>sb", "<Plug>PickerFindBuffers", desc="Find buffers")
    keymap.nmap("<leader>sg", "<Plug>PickerLiveGrep", desc="Live grep")
    keymap.nmap("<leader>sw", "<Plug>PickerWordGrep", desc="Grep word")
    keymap.nmap("<leader>s/", "<Plug>PickerBufferLines", desc="Search lines")
    keymap.nmap("<leader>sd", "<Plug>PickerDiagnostics", desc="Diagnostics")
    keymap.nmap("<leader>sp", "<Plug>PickerCommands", desc="Commands")

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
    keymap.nmap("<leader>we", lambda: api.toggle_window_expand(0.75), desc="Expand window to 3/4 width")
    keymap.nmap("<leader>w<", remember(lambda: api.resize_window("h", -1)), desc="Shrink window width")
    keymap.nmap("<leader>w>", remember(lambda: api.resize_window("h", 1)), desc="Grow window width")
    keymap.nmap("<leader>w-", remember(lambda: api.resize_window("v", -1)), desc="Shrink window height")
    keymap.nmap("<leader>w+", remember(lambda: api.resize_window("v", 1)), desc="Grow window height")
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
    keymap.nmap("<C-q>", "<C-v>", desc="Visual block mode")
    keymap.vmap("gc", "<Plug>CommentaryVisual", desc="Toggle comments")
    keymap.vmap("ga", "<Plug>AlignCharPrompt", desc="Align on character")
    keymap.vmap("gA", "<Plug>AlignRegexPrompt", desc="Align on regex")

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
