
if [[ $# == 0 ]]; then
    PYTHON_VER=3.12.3
else
    PYTHON_VER=$1
fi

# install python
echo -e "\n====== Installing Python $PYTHON_VER ======\n"

# build directions:
# https://www.build-python-from-source.com/

# python build dependencies
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev

mkdir -p $HOME/tmp/python

# build python
wget https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz
tar xzf Python-${PYTHON_VER}.tgz
cd Python-${PYTHON_VER}

sudo ./configure --prefix=/opt/python/${PYTHON_VER}/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi
sudo make -j "$(nproc)"
sudo make altinstall
sudo rm $HOME/tmp/Python-${PYTHON_VER}.tgz


# add links into bin 
mkdir -p $HOME/bin
ln -sf /opt/python/$PYTHON_VER/bin/python3.* ~/bin/
python${PYTHON_VER::-2} -m pip install setuptools


if type -p python${PYTHON_VER::-2} > /dev/null; then
    echo "python$PYTHON_VER Installed" >> ~/install_progress_log.txt
else
    echo "pyenv$PYTHON_VER FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi
