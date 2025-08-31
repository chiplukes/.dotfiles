# apt install then check if install worked
# $1 app to install

sudo apt-get install -y $1
if type -p $1 > /dev/null; then
    echo "$1 Installed" >> ~/install_progress_log.txt
else
    echo "$1 FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi

