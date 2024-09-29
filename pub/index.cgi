#!/bin/sh
if [ -d /home/etk2 ]; then
  export HOME=/home/etk2
  export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH
fi
ruby ./index.rb "$@"
