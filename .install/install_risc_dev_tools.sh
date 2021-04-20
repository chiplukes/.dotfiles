# work pc setup
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
make install
export PATH=$PATH:/usr/local/share/gcc-riscv32-unknown-elf/bin/
riscv32-unknown-elf-gcc -v
