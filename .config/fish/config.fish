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
alias pa="mpv (find $HOME/Videos -name '*.mp3' | fzf)"
alias pa="mpv (find $HOME/Videos -name '*.mp4' | fzf)"
# alias xampp="sudo systemctl start mysqld httpd"

starship init fish | source
zoxide init --cmd cd fish | source
export EDITOR="nvim"

# night light
function nl
    # Define your predefined color temperature ranges and the 'Off' option
    set colors "Off\n1500K\n2000K\n3000K\n4000K\n5000K\n6000K"

    # Use fzf to display the options and capture the selected value
    set selected_color (echo -e $colors | fzf --prompt="Select Night Light Temperature: ")

    # If a color was selected, apply it with redshift
    if test -n "$selected_color"
        if test "$selected_color" = "Off"
            redshift -x  # Turn off redshift
        else
            redshift -O $selected_color  # Apply the selected temperature
        end
    else
        echo "No selection made."
    end
end

# uv
fish_add_path "/home/timothy/.local/bin"
