git clone --separate-git-dir=$HOME/.dotfiles https://github.com/chiplukes/.dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
# call using the following command:
#https://gist.githubusercontent.com/chiplukes/ed6da5b2936e30b42897f0cf1156e196/raw/dotfiles_new_machine.sh