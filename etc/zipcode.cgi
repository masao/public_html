#!/bin/sh
# $Id$
# <title>Õπ ÿ»÷πÊ∏°∫˜</title>
LIBDIR=/home/etk/lib
if [ -d $LIBDIR ]; then
    LD_LIBRARY_PATH=$LIBDIR
    export LD_LIBRARY_PATH
    ruby -I $LIBDIR ./zipcode.rb
else
    exec ./zipcode.rb
fi
