# Language manager initializations — order matters: pyenv before rbenv avoids shim conflicts
eval "$(pyenv init -)"
eval "$(rbenv init - zsh)"
