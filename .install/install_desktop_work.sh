# work pc setup

log_file=~/install_progress_log.txt

. ./install_base.sh $log_file

# Install summary
echo -e "\n====== Summary ======\n"
cat $log_file
echo
rm $log_file
