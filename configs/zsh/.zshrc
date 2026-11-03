# ~/.zshrc — Netmask OS (hacker edition)

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_dups hist_reduce_blanks
setopt autocd correct

# completion
autoload -Uz compinit && compinit -d ~/.zcompdump

# --- prompt: netmask@netmask-os:~$ in matrix green ---
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' (%b)'
precmd() { vcs_info }
PROMPT='%F{green}netmask@netmask-os%f:%F{cyan}%~%f${vcs_info_msg_0_:+%F{yellow}${vcs_info_msg_0_}}%f%F{green}$%f '
RPROMPT='%F{8}[%*]%f'

# aliases
alias ls='ls --color=auto'
alias ll='ls -lahF'
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me && echo'

# editor
export EDITOR=nvim
export VISUAL=nvim

# --- RE toolchain paths ---
export RUSTUP_HOME=/opt/rustup
export CARGO_HOME=~/.cargo
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH"
[ -d /opt/nodejs/bin ]   && PATH="/opt/nodejs/bin:$PATH"
[ -d /usr/local/go/bin ] && PATH="/usr/local/go/bin:$PATH"
export PATH="$PATH"
export EXPLOITDB_PATH=/opt/exploitdb
export NUCLEI_TEMPLATES_PATH=~/nuclei-templates

# --- quick aliases ---
alias tools='netmask-tools'
alias learn='netmask-learn'
alias crack='netmask-crackmes'
alias doctor='netmask-tools doctor'
alias msf='msfconsole -q'
alias serve='python3 -m http.server 8000'
alias matrix='cmatrix -C green'
alias gdb-gef='gdb -q'
alias pgrok='python3 -m pwntools'

umask 022
