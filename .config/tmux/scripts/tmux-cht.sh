#!/usr/bin/env bash
selected=`cat $HOME/.config/tmux/cht-languages $HOME/.config/tmux/cht-commands | fzf`
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if grep -qs "$selected" $HOME/.config/tmux/cht-languages; then
    query=`echo $query | tr ' ' '+'`
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl -s cht.sh/$selected/$query | less -R"
else
    tmux neww bash -c "curl -s cht.sh/$selected~$query | less -R"
fi
