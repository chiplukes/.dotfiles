# install neovim
echo -e "\n====== Install neovim ======\n"

sudo add-apt-repository ppa:neovim-ppa/stable -y
sudo apt-get update -y

# install neovim
sudo apt-get install neovim

mkdir $HOME/.config
mkdir $HOME/.config/nvim
cd $HOME/.config/nvim
git clone https://github.com/chiplukes/init.vim.git cfg
cd cfg
sh install.sh

# Note: need to run :PlugInstall upon first opening of nvim
cd $HOME/.config/nvim

python3.12 -m venv .venv
$HOME/.config/nvim/.venv/bin/python -m pip install --upgrade pip
$HOME/.config/nvim/.venv/bin/python -m pip install neovim

if type -p nvim > /dev/null; then
    echo "nvim Installed" >> ~/install_progress_log.txt
else
    echo "nvim FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi

