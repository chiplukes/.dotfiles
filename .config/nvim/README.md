# kickstart.nvim

## Introduction

A starting point for Neovim that is:

* Small
* Single-file
* Completely Documented

**NOT** a Neovim distribution, but instead a starting point for your configuration.

## Installation

### Install Neovim

Kickstart.nvim targets *only* the latest
['stable'](https://github.com/neovim/neovim/releases/tag/stable) and latest
['nightly'](https://github.com/neovim/neovim/releases/tag/nightly) of Neovim.
If you are experiencing issues, please make sure you have the latest versions.

### Install External Dependencies

External Requirements:
- Basic utils: `git`, `make`, `unzip`, C Compiler (`gcc`)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation),
  [fd-find](https://github.com/sharkdp/fd#installation)
- Clipboard tool (xclip/xsel/win32yank or other depending on the platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `vim.g.have_nerd_font` in `init.lua` to true
- Emoji fonts (Ubuntu only, and only if you want emoji!) `sudo apt install fonts-noto-color-emoji`
- Language Setup:
  - If you want to write Typescript, you need `npm`
  - If you want to write Golang, you will need `go`
  - etc.

> [!NOTE]
> See [Install Recipes](#Install-Recipes) for additional Windows and Linux specific notes
> and quick install snippets

### Install Kickstart

> [!NOTE]
> [Backup](#FAQ) your previous configuration (if any exists)

Neovim's configurations are located under the following paths, depending on your OS:

| OS | PATH |
| :- | :--- |
| Linux, MacOS | `$XDG_CONFIG_HOME/nvim`, `~/.config/nvim` |
| Windows (cmd)| `%localappdata%\nvim\` |
| Windows (powershell)| `$env:LOCALAPPDATA\nvim\` |

#### Recommended Step

[Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
so that you have your own copy that you can modify, then install by cloning the
fork to your machine using one of the commands below, depending on your OS.

> [!NOTE]
> Your fork's URL will be something like this:
> `https://github.com/<your_github_username>/kickstart.nvim.git`

You likely want to remove `lazy-lock.json` from your fork's `.gitignore` file
too - it's ignored in the kickstart repo to make maintenance easier, but it's
[recommended to track it in version control](https://lazy.folke.io/usage/lockfile).

#### Clone kickstart.nvim

> [!NOTE]
> If following the recommended step above (i.e., forking the repo), replace
> `nvim-lua` with `<your_github_username>` in the commands below

<details><summary> Linux and Mac </summary>

```sh
git clone https://github.com/chiplukes/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

</details>

<details><summary> Windows </summary>

If you're using `cmd.exe`:

```
git clone https://github.com/chiplukes/kickstart.nvim.git "%localappdata%\nvim"
```

If you're using `powershell.exe`

```
git clone https://github.com/chiplukes/kickstart.nvim.git "${env:LOCALAPPDATA}\nvim"
```

</details>

### Post Installation

Start Neovim

```sh
nvim
```

That's it! Lazy will install all the plugins you have. Use `:Lazy` to view
the current plugin status. Hit `q` to close the window.

#### Read The Friendly Documentation

Read through the `init.lua` file in your configuration folder for more
information about extending and exploring Neovim. That also includes
examples of adding popularly requested plugins.

> [!NOTE]
> For more information about a particular plugin check its repository's documentation.


### Getting Started

[The Only Video You Need to Get Started with Neovim](https://youtu.be/m8C0Cq9Uv9o)

### FAQ

* What should I do if I already have a pre-existing Neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the Neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to kickstart?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, you can install the kickstart
    configuration in `~/.config/nvim-kickstart` and create an alias:
    ```
    alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
    ```
    When you run Neovim using `nvim-kickstart` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-kickstart`. You can apply this approach to any Neovim
    distribution that you would like to try out.
* What if I want to "uninstall" this configuration:
  * See [lazy.nvim uninstall](https://lazy.folke.io/usage#-uninstalling) information
* Why is the kickstart `init.lua` a single file? Wouldn't it make sense to split it into multiple files?
  * The main purpose of kickstart is to serve as a teaching tool and a reference
    configuration that someone can easily use to `git clone` as a basis for their own.
    As you progress in learning Neovim and Lua, you might consider splitting `init.lua`
    into smaller parts. A fork of kickstart that does this while maintaining the
    same functionality is available here:
    * [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim)
  * Discussions on this topic can be found here:
    * [Restructure the configuration](https://github.com/nvim-lua/kickstart.nvim/issues/218)
    * [Reorganize init.lua into a multi-file setup](https://github.com/nvim-lua/kickstart.nvim/pull/473)

### Install Recipes

Below you can find OS specific install instructions for Neovim and dependencies.

After installing all the dependencies continue with the [Install Kickstart](#Install-Kickstart) step.

#### Windows Installation

<details><summary>Windows with Microsoft C++ Build Tools and CMake</summary>
Installation may require installing build tools and updating the run command for `telescope-fzf-native`

See `telescope-fzf-native` documentation for [more details](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation)

This requires:

- Install CMake and the Microsoft C++ Build Tools on Windows

```lua
{'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
```
</details>
<details><summary>Windows with gcc/make using chocolatey</summary>
Alternatively, one can install gcc and make which don't require changing the config,
the easiest way is to use choco:

1. install [chocolatey](https://chocolatey.org/install)
either follow the instructions on the page or use winget,
run in cmd as **admin**:
```
winget install --accept-source-agreements chocolatey.chocolatey
```

2. install all requirements using choco, exit the previous cmd and
open a new one so that choco path is set, and run in cmd as **admin**:
```
choco install -y neovim git ripgrep wget fd unzip gzip mingw make
```
</details>
<details><summary>WSL (Windows Subsystem for Linux)</summary>

```
wsl --install
wsl
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>

#### Linux Install
<details><summary>Ubuntu Install Steps</summary>

```
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip neovim
```
</details>
<details><summary>Debian Install Steps</summary>

```
sudo apt update
sudo apt install make gcc ripgrep unzip git xclip curl

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
```
</details>
<details><summary>Fedora Install Steps</summary>

```
sudo dnf install -y gcc make git ripgrep fd-find unzip neovim
```
</details>

<details><summary>Arch Install Steps</summary>

```
sudo pacman -S --noconfirm --needed gcc make git ripgrep fd unzip neovim
```
</details>

## Keybindings

Below is a summary of the custom keybindings defined in this configuration. Many are designed to mirror familiar VS Code shortcuts or workflows. Press `<leader>` (space by default unless changed) followed by the listed keys.

### Conventions
* `<leader>`: Your configured leader key
* Mode prefixes: (n) Normal, (v) Visual, (t) Terminal, (o) Operator-pending
* Items without a mode are Normal mode by default
* Use `:map <lhs>` inside Neovim to inspect any mapping
* Which-Key popup (`<leader>` pause) will show discoverable groups like `[S]earch`, `[T]oggle`, etc.

### Core Navigation & Buffers
* `Alt-h` / `Alt-l`: Previous / Next buffer (tabs in your mental model)
* `Alt-j` / `Alt-k`: Move focus to lower / upper window
* `<leader>wv`: Vertical split
* `<leader>wc`: Close window
* `<leader>wf`: Only (close others)
* `<leader>we`: Open netrw explorer
* `s`: Flash jump (EasyMotion-style)
* `sj`: Flash jump (explicit keymap across normal/visual/operator)
* `S`: Flash Treesitter mode (normal/visual/operator)

### Search / Picking
* `<leader>of`: File picker (Snacks)
* `<leader>ff`: Live grep / project search (Snacks)
* `<leader>cp`: Command palette (Snacks)

### Diagnostics & LSP
* `ge`: Go to next diagnostic (your VS Code style mapping)
* `[d` / `]d`: Previous / Next diagnostic
* `<leader>e`: Floating diagnostic for current line
* `<leader>q`: Populate location list with diagnostics
* `gh`: Hover (LSP info)
* `go`: Document symbols / outline
* `<C-.>` (n/v): Code actions (VS Code quick-fix style)
* `<leader>.`: Alternate code action trigger
* `<leader>rf` (n/v): Format document / selection (async LSP formatting)
* `<leader>y`: Accept suggestion (placeholder – currently triggers code action)
* `<leader>u`: Hide diagnostics (custom hide mapping)
* `<leader>f`: Format buffer (Conform explicit key binding)

### Completion (blink.cmp custom mappings)
* `<C-Space>`: Show completion / toggle docs
* `<C-n>` / `<C-p>`: Next / Previous item
* `<C-y>`: Accept
* `<C-u>` / `<C-e>`: Hide menu
* `<Tab>` / `<S-Tab>`: Snippet forward / backward jump

### Terminal
* `<Esc><Esc>` (t): Exit terminal mode (maps to `<C-\><C-n>`)

### Editing / Marks / Multi-cursor Adjacent
* `<Esc>` (n): Clear search highlight
* `<Esc>` (insert): Remapped to `<C-c>` for reliable exit insert
* `<leader>pr`: Paste from yank register ("0 register)
* `<leader>ca` (visual): Example multi-cursor style substitution inside selection
* Marks / Bookmarks:
  * `<leader>mm`: Set next available mark (bookmark toggle)
  * `<leader>ml`: List marks
  * `<leader>mn`: Next mark
  * `<leader>mp`: Previous mark

### Flash (EasyMotion-like) Extended
* `sj` (n/x/o): Flash jump
* `S` (n/x/o): Treesitter object jump
* `r` (o): Remote flash
* `R` (o/x): Treesitter search

### Misc
* `<leader>cm`: Code actions (Context Menu analog)
* `[OK]` message on startup indicates Python → uv interceptor loaded (from profile)

### Dynamic / Plugin-Provided (Not Hard-Coded Here)
Some leader groups are declared for discovery via Which-Key:
* `<leader>s`: [S]earch group (populated by plugins/snacks/telescope-like pickers)
* `<leader>t`: [T]oggle group (if toggles registered elsewhere)
* `<leader>h`: Git hunk actions (when using a git/sign plugin that registers them)

### Tips
* Use `:verbose map <lhs>` to see where a mapping was last defined
* Temporarily bypass a mapping with an initial `<C-v>` before the key
* For conflicting plugin mappings, check lazy.nvim plugin specs or disable in opts
* `verbose nmap` -see what normal mappings are


# Todos:
---
If adding new mappings, keep them centralized in `lua/core/keymaps.lua` for maintainability.

after removing stylelua from mason, may need to add:
If you want Lua formatting to still work, install stylua system-wide with: winget install JohnnyMorganz.StyLua

figure out good way to work with a terminal

bookmarks!

wezterm config

dashboards for most common things
* exit dashboard go back to session?

resize windows is annoying

better groups in which-key
* organize code actions
* leader c (code things)
* leader s (search things)
* leader m (marker things)
* leader f (file things)
* leader e (editor stuff, file explorer window)

python formatter/linter ignore line length + other things

helper function to print all keymaps to a file?
