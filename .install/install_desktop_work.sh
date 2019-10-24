# work pc setup

. ./install_base.sh
. ./install_pyenv.sh
. ./install_neovim.sh

# Install summary
echo -e "\n====== Summary ======\n"
cat ~/install_progress_log.txt
echo
rm ~/install_progress_log.txt
