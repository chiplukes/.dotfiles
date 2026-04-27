from __future__ import annotations

from typing import TYPE_CHECKING

from peovim.core.style import Style
from peovim.syntax.themes import Theme, register_theme


if TYPE_CHECKING:
    from peovim.api.editor import EditorAPI

import logging

# logging.getLogger().setLevel(logging.DEBUG)
logging.getLogger("peovim").info("init.py -begin")


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
        "text.title": Style(fg="#569CD6"),
        "text.strong": Style(fg="#569CD6", attrs=1),
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
        plugin_manager.load("peovim.plugins.guess_indent")
        plugin_manager.load("peovim.plugins.todo")
        plugin_manager.load("peovim.plugins.gitsigns")
        plugin_manager.load("peovim.plugins.svnsigns")
        plugin_manager.load("peovim.plugins.picker")
        plugin_manager.load("peovim.plugins.fquick")
        plugin_manager.load("peovim.plugins.autopairs")
        plugin_manager.load("peovim.plugins.commentary")
        plugin_manager.load("peovim.plugins.surround")
        plugin_manager.load("peovim.plugins.align")
        plugin_manager.load("peovim.plugins.formatter")
        plugin_manager.load("peovim.plugins.which_key")
        plugin_manager.load("peovim.plugins.session")
        plugin_manager.load("peovim.plugins.explorer")
        plugin_manager.load("peovim.plugins.markers")
        plugin_manager.load("peovim.plugins.compare")
        plugin_manager.load("peovim.plugins.diagnostics_panel")
        plugin_manager.load("peovim.plugins.outline")
        plugin_manager.load("peovim.plugins.references_panel")
        # References panel preview: "float" (popup, cursor stays put) | "cursor" (navigates like outline)
        from peovim.plugins import references_panel

        references_panel.configure(preview_mode="float", preview_syntax=True)
        plugin_manager.load("peovim.plugins.workspace_symbols")
        plugin_manager.load("peovim.plugins.repl")
        plugin_manager.load("peovim.plugins.dashboard")
        plugin_manager.load("peovim.plugins.editorconfig")
        plugin_manager.load("peovim.plugins.lsp")
        plugin_manager.load("peovim.plugins.editor_utils")
        plugin_manager.load("peovim.plugins.flash")
        plugin_manager.load("peovim.plugins.local_history")
        plugin_manager.load("peovim.plugins.perf_panel")

        plugins.load("peovim.plugins.copilot")
        from peovim.plugins import copilot

        from peovim.plugins import verilog_lsp as _verilog_lsp

        _verilog_lsp.configure(
            # Comma-separated Verible rule overrides.
            # Prefix with - to disable, + to enable.  Examples:
            #   "-line-length"         suppress line-too-long warnings
            #   "-no-trailing-spaces"
            #   "-module-filename"     don't require filename == module name
            verible_rules=[
                "-line-length",
                "-no-trailing-spaces",
                "-explicit-parameter-storage-type",
                "-explicit-function-lifetime",
                "-explicit-task-lifetime",
            ]
        )
        plugins.load("peovim.plugins.verilog_lsp")

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
    options.set("scrollbar", True)
    options.set("dashboard_logo", """\
  ██████╗ ███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ██╔══██╗██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██████╔╝█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██╔═══╝ ██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║     ███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝     ╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝""")
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

    # ── Markers ───────────────────────────────────────────────────────────
    keymap.ngroup("<leader>m", "Markers")
    keymap.ngroup("<leader>mg", "Marker groups")
    keymap.nmap("<leader>mn", remember("<Plug>MarkerNext"), desc="Next marker")
    keymap.nmap("<leader>mp", remember("<Plug>MarkerPrev"), desc="Prev marker")
    keymap.nmap("<leader>me", "<Plug>MarkerText", desc="Marker annotation")
    keymap.nmap("<leader>ma", "<Plug>MarkerAdd", desc="Add marker")
    keymap.nmap("<leader>md", "<Plug>MarkerDelete", desc="Delete marker")
    keymap.nmap("<leader>mv", "<Plug>MarkerView", desc="Toggle marker sidebar")
    keymap.nmap("<leader>mgc", "<Plug>MarkerGroupCreate", desc="Create marker group")
    keymap.nmap("<leader>mgs", "<Plug>MarkerGroupSelect", desc="Select marker group")
    keymap.nmap("<leader>mgr", "<Plug>MarkerGroupRename", desc="Rename marker group")
    keymap.nmap("<leader>mgd", "<Plug>MarkerGroupDelete", desc="Delete marker group")

    # ── Code/LSP ──────────────────────────────────────────────────────────
    keymap.ngroup("<leader>c", "Code")
    keymap.nmap("<leader>ch", lambda: lsp.hover(), desc="Hover docs")
    keymap.nmap("<leader>ca", lambda: lsp.code_actions(), desc="Code actions")
    keymap.nmap(
        "<leader>ci", lambda: lsp.toggle_inlay_hints(), desc="Toggle inlay hints"
    )
    keymap.ngroup("<leader>cs", "Search")
    keymap.nmap("<leader>csd", lambda: lsp.document_symbols(), desc="Document symbols")
    keymap.nmap(
        "<leader>csw", lambda: lsp.workspace_symbols(), desc="Workspace symbols"
    )
    keymap.nmap("<leader>cd", lambda: lsp.definition(), desc="Go to definition")
    keymap.ngroup("<leader>cg", "Goto")
    keymap.nmap(
        "<leader>cgi", lambda: lsp.implementation(), desc="Go to implementation"
    )
    keymap.nmap(
        "<leader>cgt", lambda: lsp.type_definition(), desc="Go to type definition"
    )
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

    # ── Diff/Compare ──────────────────────────────────────────────────────────
    # Remove compare plugin's default <leader>c* bindings (conflict with Code group)
    for _k in (
        "<leader>c1",
        "<leader>c2",
        "<leader>cc",
        "<leader>cj",
        "<leader>ck",
        "<leader>cs",
    ):
        keymap.nunmap(_k)
    keymap.ngroup("<leader>d", "Diff")
    keymap.nmap("<leader>d1", "<Plug>CompareSelect1", desc="Compare file 1")
    keymap.nmap("<leader>d2", "<Plug>CompareSelect2", desc="Compare file 2")
    keymap.nmap("<leader>dc", "<Plug>CompareSelected", desc="Compare selected files")
    keymap.nmap("<leader>dj", "<Plug>CompareNextDiff", desc="Next compare diff")
    keymap.nmap("<leader>dk", "<Plug>ComparePrevDiff", desc="Prev compare diff")
    keymap.nmap("<leader>ds", "<Plug>CompareStop", desc="Stop compare")
    keymap.nmap("<leader>dm12", "<Plug>CompareMerge12", desc="Merge left to right")
    keymap.nmap("<leader>dm21", "<Plug>CompareMerge21", desc="Merge right to left")

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
    keymap.nmap(
        "<leader>we",
        lambda: api.toggle_window_expand(0.75),
        desc="Expand window to 3/4 width",
    )
    keymap.nmap(
        "<leader>w<",
        remember(lambda: api.resize_window("h", -1)),
        desc="Shrink window width",
    )
    keymap.nmap(
        "<leader>w>",
        remember(lambda: api.resize_window("h", 1)),
        desc="Grow window width",
    )
    keymap.nmap(
        "<leader>w-",
        remember(lambda: api.resize_window("v", -1)),
        desc="Shrink window height",
    )
    keymap.nmap(
        "<leader>w+",
        remember(lambda: api.resize_window("v", 1)),
        desc="Grow window height",
    )
    keymap.nmap(
        "<leader>wh", remember(lambda: api.focus_window("h")), desc="Window left / prev"
    )
    keymap.nmap(
        "<leader>wl",
        remember(lambda: api.focus_window("l")),
        desc="Window right / next",
    )
    keymap.nmap(
        "<leader>wj", remember(lambda: api.focus_window("j")), desc="Window down / next"
    )
    keymap.nmap(
        "<leader>wk", remember(lambda: api.focus_window("k")), desc="Window up / prev"
    )

    # ── Window/Sidebar navigation (Alt + hjkl) ───────────────────────────
    # Alt-h/l wrap in both directions across editor windows.
    # When the sidebar is open it participates as the leftmost item in that cycle.
    # While the sidebar is focused, Alt-j/k cycle panels.
    keymap.nmap("<A-h>", "<Plug>SidebarFocusLeft", desc="Sidebar focus / window left")
    keymap.nmap("<A-l>", "<Plug>SidebarFocusRight", desc="Editor focus / window right")
    keymap.nmap(
        "<A-j>", "<Plug>SidebarNextPanel", desc="Sidebar next panel / window down"
    )
    keymap.nmap(
        "<A-k>", "<Plug>SidebarPrevPanel", desc="Sidebar prev panel / window up"
    )

    # ── Sidebar-internal keys (only active while sidebar is focused) ──────
    api.ui.sidebar_nmap("[", "SidebarShrink")
    api.ui.sidebar_nmap("]", "SidebarGrow")
    api.ui.sidebar_nmap("q", "SidebarClose")
    api.ui.sidebar_nmap("<Esc>", "SidebarClose")

    # ── Bottom panel ──────────────────────────────────────────────────────
    keymap.nmap("<A-p>", "<Plug>BottomPanelToggle", desc="Toggle bottom panel")

    # ── Bottom panel-internal keys (only active while panel is focused) ───
    api.ui.bottom_nmap("[", "BottomPanelShrink")
    api.ui.bottom_nmap("]", "BottomPanelGrow")
    api.ui.bottom_nmap("q", "BottomPanelClose")
    api.ui.bottom_nmap("<Esc>", "BottomPanelBlur")
    api.ui.bottom_nmap("<", "BottomPanelPrevTab")
    api.ui.bottom_nmap(">", "BottomPanelNextTab")

    # ── Panel placement (sidebar or bottom) ───────────────────────────────
    # Panels register to their default host inside each plugin. To relocate
    # a panel, call move_panel() after plugins are loaded:
    #
    #   api.ui.move_panel("explorer",          "bottom")
    #   api.ui.move_panel("markers",           "bottom")
    #   api.ui.move_panel("outline",           "bottom")
    #   api.ui.move_panel("references",        "bottom")
    #   api.ui.move_panel("workspace-symbols", "bottom")
    #   api.ui.move_panel("diagnostics",       "bottom")

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
        plugin_manager.load("peovim.plugins.session_additions")
        plugin_manager.load("peovim.plugins.tabs_to_spaces")

        # options.set("local_history_root", "")

    # Add servers that are not auto-detected here if needed.
    # Example:
    # lsp.register_server("sh", ["bash-language-server", "start"])

    api.git.verbose = True  # show git command output in messages for debugging

    # ── Verilog / RTL ─────────────────────────────────────────────────────
    from peovim.plugins import verilog_lsp as _vl

    keymap.ngroup("<leader>r", "RTL/Verilog")
    keymap.nmap(
        "<leader>rh", lambda: _vl.toggle_hierarchy(api), desc="Verilog hierarchy panel"
    )
    keymap.nmap(
        "<leader>rt", lambda: _vl.trace_signal(api), desc="Verilog trace signal"
    )
    keymap.nmap(
        "<leader>rr", lambda: _vl.reparse(api), desc="Verilog re-parse workspace"
    )

    # ── Copilot ────────────────────────────────────────────────────────
    keymap.imap("<C-y>", copilot.accept, desc="Accept Copilot suggestion")
    keymap.imap("<A-]>", copilot.cycle_next, desc="Next Copilot suggestion")
    keymap.imap("<A-[>", copilot.cycle_prev, desc="Prev Copilot suggestion")
    copilot.debounce_ms = 350  # ms to wait after keystroke (default 350)
    copilot.max_ghost_lines = 3  # lines of suggestion to show (default 3)
    copilot.auto_trigger = True  # False = manual trigger only (default True)
    # Manual trigger (when auto_trigger=False):
    # keymap.imap("<A-Space>", copilot.trigger, desc="Request Copilot suggestion")"""")"""]")"""")


logging.getLogger("peovim").info("init.py -end")
