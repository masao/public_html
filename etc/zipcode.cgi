#!/bin/sh
# $Id$
# <title>͹���ֹ渡��</title>
LIBDIR=/home/etk/lib
if [ -d $LIBDIR ]; then
    LD_LIBRARY_PATH=$LIBDIR
    export LD_LIBRARY_PATH
    ruby -I $LIBDIR ./zipcode.rb
else
    exec ./zipcode.rb
fi
