#!/bin/bash

# used by install scripts and bashrc to determine what the primary installed version of user python is.

# Choose main user python version here
export PYTHON_USER_VER_FULL="3.12.3"

# Python install directory
export PYTHON_USER_INSTALL_LOCATION="/opt/python/"

# removes subminor version
if [[ ${PYTHON_USER_VER_FULL: -2:1} == "." ]]; then
    # subminor version is 1 character x.y.z
    export PYTHON_USER_VER=${PYTHON_USER_VER_FULL::-2}
else
    # subminor version is 2 characters x.y.zz
    export PYTHON_USER_VER=${PYTHON_USER_VER_FULL::-3}
fi
