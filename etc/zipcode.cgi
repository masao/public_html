#!/bin/sh
# $Id$
# <title>郵便番号検索</title>

if [ -d /home/etk2 ]; then
  export HOME=/home/etk2;	# sakuraでは $HOME が未定義なので明示的に指定する
  export LD_LIBRARY_PATH=$HOME/lib;
fi
ruby -I $HOME/lib/ruby/site_ruby/1.8 ./zipcode.rb "$@"
