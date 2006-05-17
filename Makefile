# $Id$
#

HTML	= index.html profile.html history.html etc/firefox.html etc/ir-journal.html
SUBDIR	= etc

all: $(HTML) chalow

%.html: %.html.in template.html.in tohtml.rb tohtml.conf
	./tohtml.rb $< > $@

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
