# base utils needed for all installs
echo -e "\n====== Base Utils for all installs ======\n"

sudo apt-get update -y
sudo apt-get upgrade -y

sudo apt-get install -y git
if type -p git > /dev/null; then
    echo "Git Installed" >> $1
else
    echo "Git FAILED TO INSTALL!!!" >> $1
fi

sudo apt-get install -y curl
if type -p curl > /dev/null; then
    echo "curl Installed" >> $1
else
    echo "curl FAILED TO INSTALL!!!" >> $1
fi


