# fish — tabby rice
set -g fish_greeting

if status is-interactive
    # system splash on every new terminal
    command -v fastfetch >/dev/null; and fastfetch
end

# rice shortcuts
alias theme  'theme-switch'
alias walls  'wall'
alias bar    'bar-switch'

# quality of life
alias ll   'ls -lah'
alias ..   'cd ..'
alias ...  'cd ../..'
alias gs   'git status'
alias ga   'git add'
alias gc   'git commit'
alias gp   'git push'
alias mkd  'mkdir -p'

# PATH + prompt live in conf.d/rice.fish (written by install.sh)
