
# vim :set ts=2 sw=2 sts=2 et :
# ~/.zshrc: executed by zsh(1) for non-login shells.

# your project folder that we can `c [tab]` to
export PROJECTS="$HOME/projects"

# path to the local dotfiles repository
if [ -d "$HOME/.dotfiles" ]; then
  export DOTFILES="$HOME/.dotfiles"
else
  echo "could not find ~/.dotfiles directory"
  return
fi

# enable colour support
export TERM="xterm-256color"

# enable timestamps in history
export HIST_STAMPS="yyyy-mm-dd"

# set platform name so that we can run scripts based on the OS
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
  platform='linux'
  if [[ -d "/run/WSL" ]]; then
    platform_wsl='true'
  elif grep -q Microsoft /proc/version; then
    platform_wsl='true'
  else
    platform_wsl='false'
  fi
elif [[ "$unamestr" == 'Darwin' ]]; then
  # shellcheck disable=SC2034
  platform='macos'
  # shellcheck disable=SC2034
  platform_wsl='false'
fi
unset unamestr

if [ -d "$HOME/.oh-my-zsh" ]; then
  # Path to your oh-my-zsh installation.
  export ZSH="$HOME/.oh-my-zsh"

  # initialise and load oh-my-zsh
  source $DOTFILES/oh-my-zsh/oh-my-zsh.zsh
else
  # shortcut to this dotfiles path is $ZSH
  export ZSH="$DOTFILES"

  # path for loading antibody bundles
  if [ -e "$HOME/.bundles.txt" ]; then
    antibody_bundles="$HOME/.bundles.txt"
  fi
fi

###
# Load ZSH configuration
# See https://github.com/caarlos0/dotfiles/blob/master/zsh/zshrc.symlink
###

# all of our zsh files
typeset -U config_files
config_files=($DOTFILES/*/*.zsh)

# remove antibody and oh-my-zsh configuration
config_files=(${config_files:#*/oh-my-zsh/*.zsh})

# load the path files
for file in ${(M)config_files:#*/path.zsh}; do
  source "$file"
done

# load antibody plugins
if [ -n "$antibody_bundles" ]; then
  source "$antibody_bundles"
fi

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

autoload -U +X bashcompinit && bashcompinit

# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}; do
  source "$file"
done

unset config_files updated_at platform platform_wsl antibody_bundles

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
# shellcheck disable=SC1090
[ -f ~/.localrc ] && . ~/.localrc
