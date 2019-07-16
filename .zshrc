# shortcut to this dotfiles path is $ZSH
export ZSH="$HOME/.dotfiles"

# your project folder that we can `c [tab]` to
export PROJECTS="$HOME/Projects"

# enable colour support
export TERM="xterm-256color"

# enable timestamps in history
export HIST_STAMPS="yyyy-mm-dd"

# set platform name so that we can run scripts based on the OS
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  platform='macos'
fi

###
# Load ZSH configuration
# See https://github.com/caarlos0/dotfiles/blob/master/zsh/zshrc.symlink
###

# all of our zsh files
typeset -U config_files
config_files=($ZSH/*/*.zsh)

# load the path files
for file in ${(M)config_files:#*/path.zsh}; do
  source "$file"
done

# load antibody plugins
source ~/.bundles.txt

# load everything but the path and completion files
for file in ${${config_files:#*/path.zsh}:#*/completion.zsh}; do
  source "$file"
done

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit
else
  compinit -C
fi

# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}; do
  source "$file"
done

unset config_files updated_at

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# shellcheck disable=SC1090
[ -f ~/.localrc ] && . ~/.localrc

# Preferred editor for local and remote sessions, default to vim
export EDITOR='vim'
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
elif [[ "$platform" == "linux" ]]; then
  command -v gvim 1>/dev/null 2>&1 && export EDITOR='gvim'
elif [[ "$platform" == "macos" ]]; then
  command -v mvim 1>/dev/null 2>&1 && export EDITOR='mvim'
fi

# SSH defaults
export SSH_KEY_PATH="~/.ssh/id_rsa"

# We don't want cows when running Ansible
export ANSIBLE_NOCOWS=1

# Custom gitchangelog config
export GITCHANGELOG_CONFIG_FILENAME="$HOME/.gitchangelog.rc"

# Load local aliases
[ -e "$HOME/.aliases" ] && source $HOME/.aliases

# Created by markosamuli.golang Ansible role
export GOPATH=$HOME/Projects/golang
export PATH=$PATH:$GOPATH/bin
