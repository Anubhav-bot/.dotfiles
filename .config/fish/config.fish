if status is-interactive
    # Commands to run in interactive sessions can go here
end
# alias tmux-mul="~/Documents/tmux-startups/tmux-mul.sh"
# alias tmux-dycn-front="~/Documents/tmux-startups/tmux-dycn-front.sh"
# alias tmux-dycn-back="~/Documents/tmux-startups/tmux-dycn-back.sh"
# alias tmux-mis="~/Documents/tmux-startups/tmux-mis.sh"

alias gss="git status -s"
alias yt="yt-x"
alias fa="fastanime anilist"
alias pa="mpv --no-video (find $HOME -name '*.mp3' -or -name '*.webm' | fzf)"
alias pan="mpv --no-video (find $HOME -name '*-novel.mp3' -or -name '*-novel.webm' | fzf)"
alias pv="mpv (find $HOME -name '*.mp4' | fzf)"
alias pac="sudo pacman"
alias xampp="sudo systemctl start mysqld httpd"
alias xamppkill="sudo systemctl stop mysqld httpd"
alias timesync="sudo systemctl start systemd-timesyncd && sudo systemctl stop systemd-timesyncd"
alias phone="notify-send -t 3000 'Connecting to Phone' && scrcpy --tcpip=192.168.1.66 --kill-adb-on-close -K -S --power-off-on-close"

starship init fish | source
zoxide init --cmd cd fish | source
export EDITOR="nvim"

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end


set -x GPG_TTY (tty)

bind \cf "tmux-sessionizer"
bind \cy 'y'

fish_add_path "$HOME/.local/scripts/"
fish_add_path "/home/timothy/.config/emacs/bin"
fish_add_path "/home/timothy/Documents/yoink/elenapan-dotfiles/bin"

# uv
fish_add_path "/home/timothy/.local/bin"
