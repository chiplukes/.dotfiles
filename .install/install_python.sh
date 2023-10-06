
if [[ $# == 0 ]]; then
    PYTHON_VER=3.12.0
else
    PYTHON_VER=$1
fi

# install python
echo -e "\n====== Installing Python $PYTHON_VER ======\n"

# python build dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get build-dep python3

# checkout branch from github
mkdir -p $HOME/tmp/python
git clone --branch v$PYTHON_VER --single-branch https://github.com/python/cpython.git $HOME/tmp/python/v$PYTHON_VER

# build python
cd ~/tmp/python/v$PYTHON_VER
./configure --prefix=$HOME/lib/cpython/$PYTHON_VER --enable-optimizations --with-lto
make
make altinstall
mkdir -p $HOME/bin
ln -sf ~/lib/cpython/$PYTHON_VER/bin/python3.* ~/bin/

python${PYTHON_VER::-2} -m pip install setuptools

if type -p python${PYTHON_VER::-2} > /dev/null; then
    echo "python$PYTHON_VER Installed" >> ~/install_progress_log.txt
else
    echo "pyenv$PYTHON_VER FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi
