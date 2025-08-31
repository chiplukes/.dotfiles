#!/bin/bash
set -euo pipefail

echo -e "\n====== Install Neovim ======\n"

# Optional: use stable PPA (uncomment if needed newer than repo)
# sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt update
sudo apt install -y neovim python3 python3-venv python3-pip ripgrep gcc make unzip git xclip

# Create Python venv for Neovim provider
NVIM_VENV="${HOME}/.config/nvim/.venv"
if [[ ! -d "$NVIM_VENV" ]]; then
  python3 -m venv "$NVIM_VENV"
fi
"$NVIM_VENV/bin/pip" install --upgrade pip pynvim

# (Optional) write host prog hint (Lua)
NVIM_INIT_LUA="${HOME}/.config/nvim/init.lua"
if ! grep -q "python3_host_prog" "$NVIM_INIT_LUA" 2>/dev/null; then
  mkdir -p "$(dirname "$NVIM_INIT_LUA")"
  {
    echo '-- Added by install_neovim.sh'
    echo "vim.g.python3_host_prog = '${NVIM_VENV}/bin/python'"
  } >> "$NVIM_INIT_LUA"
fi

if command -v nvim >/dev/null; then
  echo "nvim Installed" >> "${HOME}/install_progress_log.txt"
else
  echo "nvim FAILED TO INSTALL!!!" >> "${HOME}/install_progress_log.txt"
fi
