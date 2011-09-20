# modify the prompt to contain git branch name if applicable
git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $ref ]]; then
    echo "[%{$fg_bold[green]%}${ref#refs/heads/}%{$reset_color%}]"
  fi
}
setopt promptsubst
export PS1='$(git_prompt_info)[${SSH_CONNECTION+"%{$fg_bold[green]%}%n@%m:"}%{$fg_bold[blue]%}%~%{$reset_color%}] '

# load our own completion functions
fpath=(~/.zsh/completion $fpath)

# completion
autoload -U compinit
compinit

# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc
export CLICOLOR=1

# history settings
setopt histignoredups
HISTFILE=~/.zsh_history
HISTSIZE=4096
SAVEHIST=4096

# awesome cd movements from zshkit
setopt autocd autopushd pushdminus pushdsilent pushdtohome cdablevars
DIRSTACKSIZE=5

# Try to correct command line spelling
setopt correct correctall

# Enable extended globbing
setopt extendedglob

# Allow [ or ] whereever you want
unsetopt nomatch

# vi mode
bindkey -v
bindkey "^F" vi-cmd-mode
bindkey jj vi-cmd-mode

# handy keybindings
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# use vim as the visual editor
export VISUAL=vim
export EDITOR=$VISUAL

# load rbenv if available
if which rbenv &>/dev/null ; then
  eval "$(rbenv init - --no-rehash)"
fi

# load thoughtbot/dotfiles scripts
export PATH="$HOME/.bin:$PATH"

# mkdir .git/safe in the root of repositories you trust
export PATH=".git/safe/../../bin:$PATH"

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# automatically pushd
setopt auto_pushd
export dirstacksize=5

# Allows me to cd into projects
cdpath=(. ~/code/thoughtbot/ ~/code/play/ ~/code/src/)
typeset -gU cdpath

PATH=~/bin:~/bin/scripts:/usr/local/bin:/usr/local/bin:/usr/local/sbin:/usr/local/Cellar/python/2.7/bin:$PATH

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then source "$HOME/.rvm/scripts/rvm" ; fi

# awesome cd movements from zshkit
setopt AUTOCD
setopt AUTOPUSHD PUSHDMINUS PUSHDSILENT PUSHDTOHOME
setopt cdablevars

# Enable extended globbing
setopt EXTENDED_GLOB

# load in aliases
source ~/.zshenv

# awesome completion from zshkit
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' use-cache on
zstyle ':completion:*' users resolve

# colorful ls completion
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=0;32:*.jpe=0;32:*.jpeg=0;32:*.gif=0;32:*.bmp=0;32:*.pbm=0;32:*.pgm=0;32:*.ppm=0;32:*.tga=0;32:*.xbm=0;32:*.xpm=0;32:*.tif=0;32:*.tiff=0;32:*.png=0;32:*.eps=0;32:*.mpg=0;32:*.mpeg=0;32:*.avi=0;32:*.fli=0;32:*.gl=0;32:*.dl=0;32:*.xcf=0;32:*.xwd=0;32:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.flac=01;35:*.m4a=01;35:*.mpc=01;35:*.o=01;33:*.c=01;35:*.m=01;35:*.h=01;35:*.rb=01;35:*.pl=01;35:*.py=01;35:*.sh=01;35:*.m=01;35:*akefile=0;35:*tags=01;32:*~=01;30:*.swp=01;30:*README=01;31:*README.*=01;31:*readme=00;31:*.tex=01;31:*.htm=01;31:*.html=01;31:*.pdf=00;31:*.PDF=00;31:*.ps=00;31:*.PS=00;31:*.png=00;31:*.PNG=00;31:*.jpg=00;31:*.JPG=00;31:*.jpeg=00;31:*.JPEG=00;31:';
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Enable menu completion
zstyle ':completion*:default' menu 'select=1'

# allow approximate matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' auto-description 'Specify: %d'
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' verbose true
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns \
'*?.(o|c~|zwc)' '*?~'

# no binary files for vim
zstyle ':completion:*:vim:*' ignored-patterns '*.(o|a|so|aux|dvi|log|swp|fig|bbl|blg|bst|idx|ind|out|toc|class|pdf|ps|pyc)'

# tar files
zstyle ':completion:*:tar:*' files '*.tar|*.tgz|*.tz|*.tar.Z|*.tar.bz2|*.tZ|*.tar.gz'

# Group relatex matches:
zstyle ':completion:*' group-name ''
zstyle ':completion:*:-command-:*:(commands|builtins|reserved-words-aliases)' group-name commands

# Separate man page sections
zstyle ':completion:*:manuals' seperate-sections true

# Separate comand line options and descriptions with #
zstyle ':completion:*' list-separator '#'

# Generate descriptions for arguments
zstyle ':completion:*' auto-description 'specify: %d'

# Give long completion options in a list. tab to advance.
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# reload completion
autoload -Uz compinit
compinit
