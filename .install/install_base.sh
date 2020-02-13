# base utils needed for all installs
echo -e "\n====== Base Utils for all installs ======\n"

sudo apt-get update -y
sudo apt-get upgrade -y

. ./apt_install_check.sh git
. ./apt_install_check.sh curl
. ./apt_install_check.sh subversion

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

. ./apt_install_check.sh ripgrep
