if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias tmux-mul="~/Documents/tmux-startups/tmux-mul.sh"
alias tmux-dycn-front="~/Documents/tmux-startups/tmux-dycn-front.sh"
alias tmux-dycn-back="~/Documents/tmux-startups/tmux-dycn-back.sh"
alias tmux-mis="~/Documents/tmux-startups/tmux-mis.sh"

alias gss="git status -s"
alias xampp="sudo systemctl start mysqld httpd"

starship init fish | source
zoxide init --cmd cd fish | source
export GPG_TTY=$(tty)

# yazi stuff
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
# end yazi stuff
