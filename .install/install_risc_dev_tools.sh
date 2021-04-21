# riscv gnu toolchain setup
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y autotools-dev
sudo apt-get install -y curl
sudo apt-get install -y libmpc-dev
sudo apt-get install -y libmpfr-dev
sudo apt-get install -y libgmp-dev
sudo apt-get install -y gawk
sudo apt-get install -y build-essential
sudo apt-get install -y bison
sudo apt-get install -y flex
sudo apt-get install -y texinfo
sudo apt-get install -y gperf
sudo apt-get install -y libtool
sudo apt-get install -y patchutils
sudo apt-get install -y bc
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y libexpat-dev


mkdir -p ~/tmp
cd ~/tmp
git clone --depth=1 git://gcc.gnu.org/git/gcc.git gcc
git clone --depth=1 git://sourceware.org/git/binutils-gdb.git
git clone --depth=1 git://sourceware.org/git/newlib-cygwin.git
mkdir combined
cd combined
ln -s ../newlib-cygwin/* .
ln -sf ../binutils-gdb/* .
ln -sf ../gcc/* .
mkdir build
cd build	
../configure --target=riscv32-unknown-elf --enable-languages=c --disable-shared --disable-threads --disable-multilib --disable-gdb --disable-libssp --with-newlib --with-arch=rv32ima --with-abi=ilp32 --prefix=/usr/local/share/gcc-riscv32-unknown-elf
make -j4
make
sudo make install
export PATH=$PATH:/usr/local/share/gcc-riscv32-unknown-elf/bin/
riscv32-unknown-elf-gcc -v
