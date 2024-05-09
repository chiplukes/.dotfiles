#!/bin/bash

# this script allows alternate version passed as arg (if desired)
if [[ $# == 0 ]]; then
    # get user python version
    source "${HOME}"/bash_scripts/setpython.bash
    PYTHON_VER_FULL=${PYTHON_USER_VER_FULL}
    PYTHON_VER=${PYTHON_USER_VER}
    PYTHON_INSTALL_LOCATION=${PYTHON_USER_INSTALL_LOCATION}
else
    PYTHON_VER_FULL=$1
    if [[ ${PYTHON_VER_FULL: -2:1} == "." ]]; then
        # subminor version is 1 character x.y.z
        PYTHON_VER=${PYTHON_USER_VER::-2}
    else
        # subminor version is 2 characters x.y.zz
        PYTHON_VER=${PYTHON_USER_VER::-3}
    fi
    PYTHON_INSTALL_LOCATION="/opt/python/"
fi

# install python
echo -e "\n====== Installing Python $PYTHON_VER ======\n"

# python build dependencies
sudo apt-get update -y
sudo apt-get upgrade -y

mkdir -p "${HOME}"/tmp/python
cd "${HOME}"/tmp/python || exit

if [[ ${PYTHON_VER_FULL} == "3.12.3" ]]; then
    # Python 3.12.3
    # build directions:
    # https://www.build-python-from-source.com/

    # dependencies
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev

    # build python
    wget https://www.python.org/ftp/python/"${PYTHON_VER_FULL}"/Python-"${PYTHON_VER_FULL}".tgz
    tar xzf Python-"${PYTHON_VER_FULL}".tgz
    cd Python-"${PYTHON_VER_FULL}" || exit

    sudo ./configure --prefix="${PYTHON_INSTALL_LOCATION}${PYTHON_VER_FULL}"/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi
    sudo make -j "$(nproc)"
    sudo make altinstall
    sudo rm "${HOME}"/tmp/python/Python-"${PYTHON_VER_FULL}".tgz

    # add links into bin 
    mkdir -p "${HOME}"/bin
    ln -sf "${PYTHON_INSTALL_LOCATION}${PYTHON_VER_FULL}"/bin/python3.* ~/bin/

elif [[ ${PYTHON_VER_FULL} == "3.11.6" ]]; then
    # Python 3.11.6
    # build directions:
    # https://www.build-python-from-source.com/

    # dependencies
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev liblzma-dev tk-dev

    # build python
    wget https://www.python.org/ftp/python/"${PYTHON_VER_FULL}"/Python-"${PYTHON_VER_FULL}".tgz
    tar xzf Python-"${PYTHON_VER_FULL}".tgz
    cd Python-"${PYTHON_VER_FULL}" || exit

    sudo ./configure --prefix="${PYTHON_INSTALL_LOCATION}${PYTHON_VER_FULL}"/ --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi
    sudo make -j "$(nproc)"
    sudo make altinstall
    sudo rm "${HOME}"/tmp/python/Python-"${PYTHON_VER_FULL}".tgz

    # add links into bin 
    mkdir -p "${HOME}"/bin
    ln -sf "${PYTHON_INSTALL_LOCATION}${PYTHON_VER_FULL}"/bin/python3.* ~/bin/

else
    echo "Error: no build instructions for Python ${PYTHON_VER_FULL}"
    echo "Error: no build instructions for Python ${PYTHON_VER_FULL}" >> ~/install_progress_log.txt
    exit
fi


if type -p python"${PYTHON_VER}" > /dev/null; then
    echo "python${PYTHON_VER_FULL} Installed" >> ~/install_progress_log.txt
else
    echo "python${PYTHON_VER_FULL} FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi
