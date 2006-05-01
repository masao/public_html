#!/bin/sh
# $Id$
LIBDIR=/home/etk/lib
if [ -d $LIBDIR ]; then
   LD_LIBRARY_PATH=$LIBDIR
   export LD_LIBRARY_PATH
fi
exec ./zipcode.rb
