# ~/.bashrc — executed for every new interactive (non-login) bash shell
# Login shells read ~/.bash_profile or ~/.profile instead.
# Changes here take effect after: source ~/.bashrc

# ── GUARD: non-interactive shells exit immediately ─────────────
# SSH scripts, cron jobs, and subshells are non-interactive.
# Nothing below should run in those contexts.
case $- in
*i*) ;; # 'i' flag = interactive → continue
*) return ;;
esac

# ══════════════════════════════════════════════════════════════
# HISTORY
# ══════════════════════════════════════════════════════════════

# Don't save duplicate lines or lines that start with a space
# (prefix a command with a space to keep it out of history)
HISTCONTROL=ignoreboth

# Append to history file on exit instead of overwriting it
# (safe with multiple open terminals)
shopt -s histappend

# Number of lines kept in memory and on disk respectively
HISTSIZE=1000
HISTFILESIZE=2000

# ══════════════════════════════════════════════════════════════
# SHELL BEHAVIOUR
# ══════════════════════════════════════════════════════════════

# Re-check terminal window size after every command
# so $LINES and $COLUMNS stay accurate after resizing
shopt -s checkwinsize

# Make 'less' handle binary/compressed files gracefully
# (e.g. man pages, gzip files)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Detect chroot environments (e.g. debootstrap, schroot)
# and expose the name so the prompt can show it
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# ══════════════════════════════════════════════════════════════
# PROMPT
# ══════════════════════════════════════════════════════════════

# Starship handles the actual prompt — it's fast, git-aware,
# and theme-able. The PS1 blocks below are the stock Ubuntu
# fallback that Starship overrides anyway; kept for safety.

case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\n\$\n '
fi
unset color_prompt force_color_prompt

# Set terminal window/tab title to "user@host: dir"
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ══════════════════════════════════════════════════════════════
# COLOURS
# ══════════════════════════════════════════════════════════════

# Enable colour output for ls, grep, etc.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ══════════════════════════════════════════════════════════════
# ALIASES
# ══════════════════════════════════════════════════════════════

# ls shortcuts
alias ld='lsd -alF'
alias ll='ls -alF' # long list, show type indicator
alias la='ls -A'   # all files except . and ..
alias l='ls -CF'   # compact columnar output

# Notify desktop when a long command finishes: sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Source a separate aliases file if it exists
# (keeps this file short; put project-specific aliases there)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Systemd user service shortcuts
alias hug="systemctl --user restart hugo"       # restart Hugo dev server
alias lanm="systemctl --user restart lan-mouse" # restart LAN Mouse daemon

# RPCS3 PS3 emulator (force X11 — Wayland support is still experimental)
alias rpcs3='WAYLAND_DISPLAY= ~/.local/bin/rpcs3-v0.0.40-19296-e8cd6f4e_linux64.AppImage'

# Podman
alias podmanager='/home/hateem/projects/podmanager/.venv/bin/podmanager'

# ══════════════════════════════════════════════════════════════
# KEYBINDINGS (interactive shell only)
# ══════════════════════════════════════════════════════════════

if [[ $- == *i* ]]; then
    # Ctrl+F → run 'zi' (zoxide interactive directory jump)
    # zoxide learns your most-visited dirs and ranks them by frecency
    bind '"\C-f":"zi\n"'
fi

# ══════════════════════════════════════════════════════════════
# PATH
# ══════════════════════════════════════════════════════════════

# Append extra bin directories to PATH (: separated)
# ~/.local/bin   → pip install --user, pipx, custom scripts
# ~/.cargo/bin   → Rust binaries (rustup, cargo-installed tools)
# flatpak paths  → Flatpak app CLI wrappers
# ~/go/bin       → Go-installed binaries (e.g. gopls)
export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"
export PATH="$PATH:$HOME/go/bin"

# ══════════════════════════════════════════════════════════════
# COMPLETIONS
# ══════════════════════════════════════════════════════════════

# Tab-completion for commands, flags, git branches, etc.
# Only loads if not already loaded via /etc/bash.bashrc
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ══════════════════════════════════════════════════════════════
# TOOLS — PROMPT & NAVIGATION
# ══════════════════════════════════════════════════════════════

# Starship: cross-shell prompt with git, conda, language version awareness
eval "$(starship init bash)"

# Zoxide: smarter cd — learns directories you visit frequently
# Usage: z proj   → jumps to the best matching directory
#        zi       → interactive fuzzy picker (requires fzf)
eval "$(zoxide init bash)"

# ══════════════════════════════════════════════════════════════
# CONDA (Anaconda / Miniconda)
# ══════════════════════════════════════════════════════════════

# Managed by 'conda init' — initialises the conda shell functions
# and activates the base environment.
# To stop base activating automatically: conda config --set auto_activate_base false

__conda_setup="$('/home/hateem-arshad/anaconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/hateem-arshad/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/hateem-arshad/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/hateem-arshad/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# ══════════════════════════════════════════════════════════════
# FZF — FUZZY FINDER
# ══════════════════════════════════════════════════════════════

# Load fzf shell integration: adds Ctrl+T, Ctrl+R, Alt+C keybindings
# Without this line, fzf is just a standalone binary with no shell hooks
source /usr/share/doc/fzf/examples/key-bindings.bash

# FZF_DEFAULT_OPTS: appearance applied to every fzf invocation
#   --height 40%      → open inline (not full screen)
#   --layout=reverse  → input at top, results below
#   --border          → draw a box around the widget
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Keybinding reference:
#   Ctrl+T  → paste a fuzzy-found FILE path into the current command line
#   Ctrl+R  → fuzzy search through shell HISTORY
#   Alt+C   → fuzzy-find a DIRECTORY and cd into it
#
# Note: plain `fzf` just prints the selection to stdout — it cannot cd
# by itself. Alt+C is the correct binding for interactive directory jumping.
# For fast jumping to known dirs, prefer Ctrl+F (zi / zoxide).

# ══════════════════════════════════════════════════════════════
# PODMAN mount
# ══════════════════════════════════════════════════════════════

podman_fix_mounts() {
    if findmnt -n -o PROPAGATION / | grep -q shared; then
        echo "Already shared — nothing to do."
    else
        echo "Setting root mount propagation to shared..."
        sudo mount --make-rshared /
    fi
}

# ══════════════════════════════════════════════════════════════
# STARTUP
# ══════════════════════════════════════════════════════════════

# Print system info on every new shell (fastfetch reads hardware/OS data)
fastfetch

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# opencode
export PATH=/home/hateem/.opencode/bin:$PATH

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/hateem/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/hateem/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac
# Tab completion for juliaup and julia channel selection
[ -f "/home/hateem/.julia/juliaup/completions/bash.sh" ] && source "/home/hateem/.julia/juliaup/completions/bash.sh"

# <<< juliaup initialize <<<
. "$HOME/.cargo/env"
