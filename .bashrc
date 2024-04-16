#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#Variables
bsp="--break-system-packages"
phoneIp='192.168.18.55'

#aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias pf='pcmanfm'
alias kr='animdl'
alias ck='jerry'
alias ac='ani-cli -q 720p'
alias nv='lncrawl'
alias asdf='setxkbmap us dvorak'
alias aoeu='setxkbmap us'
alias p=play #function definition below
alias ps='play "save"'
alias adbp='adb connect 192.168.18.55:5555'
alias swap='swap_func'
alias bs='brightnessctl'
alias night='xrandr --output LVDS5 --brightness -0.1'


#Starship Prompt
eval "$(starship init bash)"

#PATH
export PATH="$HOME/.local/bin:$PATH"

#Autostart

#neofetch
# amixer set Speaker mute

#Keybindings

bind -x '"\C-s":"cd_with_fzf"' 
bind -x '"\C-y":"youtube-tui"'

#Functions

swap_func() {
    case $1 in 
        1|'y'|'Y')
            setxkbmap -option ctrl:swapcaps
            notify-send -t 3000 "Swapped CapsLock and Ctrl"
            printf "Swapped CapsLock and Ctrl\n"
            ;;

        0|'n'|'N')
            setxkbmap -option
            notify-send -t 3000 "Unswapped CapsLock and Ctrl"
            printf "Unswapped CapsLock and Ctrl\n"
            ;;
        *)
            notify-send -t 3000 "Invalid argument. Use 0 or 1"
            printf "Invalid argument. Use 0 or 1\n"
    esac
}

play() {
	vid="$(ls | fzf)"
	mpv "$vid" && echo "Finished playing: $vid"
    echo -e "\n"

    case $1 in
        "save")
            echo -e "Finished playing: $vid\n" > ./"history.txt"
            echo -e "Updated history.txt"
            ;;
        ?)
            echo "Not saving.."
            ;;
        *)
            echo "Usage: play &optional 'save'"
            ;;
    esac

}

cd_with_fzf() {
  local directories=$(find ~/Desktop/ ~/Documents/ ~/Videos/ ~/Games ~/.config -type d 2>/dev/null)
  local selected_dir=$(echo "$directories" | fzf --preview="tree -L 1 {}" --bind="space:toggle-preview" --preview-window=:hidden)

  if [[ -n "$selected_dir" ]]; then
    cd "$selected_dir"
  fi
}
eval "$(zoxide init --cmd cd bash)"
