# base utils needed for all installs
echo -e "\n====== Base Utils for all installs ======\n"

ubuntu_version=$(grep -oP 'VERSION_ID="\K[\d.]+' /etc/os-release)
echo "found ubuntu version: $ubuntu_version"
if [ "$ubuntu_version" == "22.04" ]; then
    echo "fixing 22.04 deb-src URIs"
    sudo cp /etc/apt/sources.list /etc/apt/sources.list~
    sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
elif [ "$ubuntu_version" == "24.04" ]; then
    echo "fixing 24.04 deb-src URIs"
    sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources~
    sudo sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
else
    echo "no URI fix needed."
fi

sudo apt-get upgrade -y
sudo apt-get update -y
. ./apt_install_check.sh git
. ./apt_install_check.sh curl
. ./apt_install_check.sh subversion

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

. ./apt_install_check.sh ripgrep


source ~/.bashrc
