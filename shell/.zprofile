if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=se exec sway
fi


export PATH="$HOME/.cargo/bin:$PATH"
export EDITOR=nvim
