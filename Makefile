# $Id$
#

# Rsync to http://masao.jpn.org/
rsync:
	./rsync.pl --exclude=test/ --exclude=private/ --delete-after \
		./ etk:www/masao/

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb
