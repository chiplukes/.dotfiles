# base utils needed for all installs
echo -e "\n====== Base Utils for all installs ======\n"

sudo apt-get update -y
sudo apt-get upgrade -y

. ./apt_install_check.sh git
. ./apt_install_check.sh curl


