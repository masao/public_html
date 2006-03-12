# $Id$
#

# Rsync to http://masao.jpn.org/
rsync:
	./rsync.pl

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb
