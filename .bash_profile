# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\]: \w\[\033[01;33m\]$(parse_git_branch)\[\033[01;34m\] \$\[\033[00m\] '

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash

  __git_complete gc _git_checkout
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

export YVM_DIR=/opt/homebrew/opt/yvm
[ -r $YVM_DIR/yvm.sh ] && . $YVM_DIR/yvm.sh

export PATH="/usr/local/opt/openssl/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$PATH:$(yarn global dir)/node_modules/.bin"
