#!/bin/sh
# $Id$
# <title>͹���ֹ渡��</title>

export HOME=/home/etk2	# sakura�Ǥ� $HOME ��̤����ʤΤ�����Ū�˻��ꤹ��
export LD_LIBRARY_PATH=$HOME/lib
ruby -I $HOME/lib/ruby/site_ruby/1.8 ./zipcode.rb "$@"
