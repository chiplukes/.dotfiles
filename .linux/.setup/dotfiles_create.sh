
# following this https://github.com/anandpiyer/.dotfiles/tree/master/.dotfiles
# script for first time setup of dotfiles
# run using: curl -Lks https://gist.githubusercontent.com/chiplukes/7c26747631b22acc379a9aed7e9ce113/raw | /bin/bash
shopt -s expand_aliases
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
source ~/.bashrc
dotfiles config --local status.showUntrackedFiles no
dotfiles remote add origin https://github.com/chiplukes/.dotfiles.git

# Add files using the following sequence:
# dotfiles add .bashrc
# dotfiles commit -m "adding file"
# dotfiles push -f --set-upstream origin master