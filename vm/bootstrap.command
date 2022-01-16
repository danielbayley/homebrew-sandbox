#! /bin/zsh --no-rcs --aliases --all-export
pushd $0:h

git config user.name | read GITHUB_USER

vm=${1:-$PWD:h:t}

alias anka="anka ${HOMEBREW_DEBUG+--debug}"
alias run="anka run $vm"
alias curl='curl --fail --silent --show-error --location'

if ! run which -s brew
then run bash -c "$(curl https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

run git credential-osxkeychain store <<< "protocol=https
host=github.com
username=$GITHUB_USER
password=$GITHUB_TOKEN"

security add-internet-password -a $GITHUB_USER -s npmjs.com -Uw $NPM_TOKEN -j NPM_TOKEN

run brew tap $GITHUB_USER/$vm

source <(brew shellenv)
tap=$HOMEBREW_REPOSITORY/Library/Taps/$GITHUB_USER/homebrew-$vm
alias run="anka run --workdir $tap/$PWD:t/dotfiles $vm"

run brew bundle --file Brewfile

run docket dock.yml