# Prerequisites:
#sudo apt-get install -y git
sudo apt-get install -y perl
sudo apt-get install -y help2man
#sudo apt-get install -y python3
sudo apt-get install -y make
sudo apt-get install -y autoconf
sudo apt-get install -y g++
sudo apt-get install -y flex bison ccache
sudo apt-get install -y libgoogle-perftools-dev
sudo apt-get install -y numactl perl-doc
sudo apt-get install -y libfl2  # Ubuntu only (ignore if gives error)
sudo apt-get install -y libfl-dev  # Ubuntu only (ignore if gives error)
sudo apt-get install -y zlibc zlib1g zlib1g-dev  # Ubuntu only (ignore if gives error)
sudo apt-get install -y mold

mkdir -p ~/tmp
cd ~/tmp
git clone https://github.com/verilator/verilator   # Only first time
## Note the URL above is not a page you can see with a browser, it's for git only

# Every time you need to build:
unsetenv VERILATOR_ROOT  # For csh; ignore error if on bash
unset VERILATOR_ROOT  # For bash
cd verilator
git pull        # Make sure git repository is up-to-date
#git tag         # See what versions exist
#git checkout master      # Use development branch (e.g. recent bug fixes)
git checkout stable      # Use most recent stable release
#git checkout v4.106       # as of 4/30/2021 need this to fix a bug in the vpi for cocotb

autoconf        # Create ./configure script
./configure     # Configure and create Makefile
make -j         # Build Verilator itself
sudo make install
