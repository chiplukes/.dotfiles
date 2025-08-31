#!/bin/bash

# find user python install version
source "${HOME}"/bash_scripts/setpython.bash

echo -e "\n====== Installing Icarus Verilog ======\n"
# stuff for icarus/myhdl
sudo apt-get install -y gperf
sudo apt-get install -y autoconf
sudo apt-get install -y flex
sudo apt-get install -y bison

# setting up Icarus Verilog
mkdir -p "${HOME}"/tmp
cd "${HOME}"/tmp || exit
git clone https://github.com/steveicarus/iverilog.git
cd iverilog || exit
#git checkout --track -b v10-branch origin/v10-branch
#git pull
sh autoconf.sh
./configure
sudo make install

if type -p iverilog > /dev/null; then
        echo "Icarus Verilog Installed" >> ~/install_progress_log.txt
    else
        echo "Icarus Verilog FAILED TO INSTALL!!!" >> ~/install_progress_log.txt
fi

echo "Setting up MyHDL"
cd "${HOME}"/tmp || exit
git clone https://github.com/jandecaluwe/myhdl.git
cd "${HOME}"/tmp/myhdl || exit

# make a temporary virtual environment
python"${PYTHON_USER_VER}" -m venv .venv
"${HOME}"/tmp/myhdl/.venv/bin/python -m pip install setuptools
# install myhdl
"${HOME}"/tmp/myhdl/.venv/bin/python setup.py install

# compile and install cosimulation vpi
cd "${HOME}"/tmp/myhdl/cosimulation/icarus && make && sudo install -m 0755 -D ./myhdl.vpi /usr/lib/ivl/myhdl.vpi
sudo cp "${HOME}"/tmp/myhdl/cosimulation/icarus/myhdl.vpi /usr/local/lib/ivl

