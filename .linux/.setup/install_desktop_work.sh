# work pc setup

. ./install_base.sh
. ./install_python.sh
. ./install_neovim.sh
. ./install_hdl_tools.sh

# Install summary
echo -e "\n====== Summary ======\n"
cat ~/install_progress_log.txt
echo
rm ~/install_progress_log.txt
