# work pc setup

# stuff for icarus/myhdl
sudo apt-get install -y gperf
sudo apt-get install -y autoconf
sudo apt-get install -y flex
sudo apt-get install -y bison

# setting up Icarus Verilog
cd ~
git clone https://github.com/steveicarus/iverilog.git
cd iverilog
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

# Setting up MyHDL
export PYTHON_EXE=$HOME/.pyenv/versions/general/bin/python
cd ~
git clone https://github.com/jandecaluwe/myhdl.git
cd ~/myhdl && sudo $PYTHON_EXE setup.py install
cd ~/myhdl/cosimulation/icarus && make && sudo install -m 0755 -D ./myhdl.vpi /usr/lib/ivl/myhdl.vpi
sudo cp $HOME/myhdl/cosimulation/icarus/myhdl.vpi /usr/local/lib/ivl

