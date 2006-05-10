# $Id$
#

all: chalow rsync

# chalow
chalow:
	cd private/ && make
	cd d/ && make

# Rsync to http://masao.jpn.org/
rsync:
	./rsync.pl --exclude=test/ --exclude=private/ --delete-after \
		./ etk:www/masao/

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb
