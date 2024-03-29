# install pyenv
echo -e "\n====== Install Pyenv ======\n"

sudo apt-get update -y
sudo apt-get upgrade -y

# python build
sudo apt-get install -y build-essential
sudo apt-get install -y libssl-dev
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y libncurses5-dev
sudo apt-get install -y libncursesw5-dev
sudo apt-get install -y libreadline-dev
sudo apt-get install -y libsqlite3-dev
sudo apt-get install -y libgdbm-dev
sudo apt-get install -y libdb5.3-dev
sudo apt-get install -y libbz2-dev
sudo apt-get install -y libexpat1-dev
sudo apt-get install -y liblzma-dev
sudo apt-get install -y libffi-dev
sudo apt-get install -y uuid-dev
sudo apt-get install -y tk-dev

# setting up pyenv to get python 3.6 on this box
# https://askubuntu.com/questions/865554/how-do-i-install-python-3-6-using-apt-get
# https://github.com/pyenv/pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

# so that this script has pyenv available
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

## so that pyenv available after script run
#echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> $HOME/.bashrc
#echo 'eval "$(pyenv init -)"' >> $HOME/.bashrc
#echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/.bashrc

if type -p pyenv > /dev/null; then
    echo "pyenv Installed" >> ~/install_progress_log.txt
else
    echo "pyenv FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi

#git clone https://github.com/pyenv/pyenv-virtualenv.git $PYENV_ROOT/plugins/pyenv-virtualenv


# install python 3.8.6
pyenv install 3.8.6
pyenv virtualenv 3.8.6 general
pyenv global general
pyenv rehash

