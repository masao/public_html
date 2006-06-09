# $Id$

HTML	= 	index.html profile.html history.html \
		etc/index.shtml \
		etc/firefox.html etc/ir-journal.html etc/unihan-onkun.html \
		software/mnewsprint/index.html

all: $(HTML) chalow

%.html: %.hikidoc template.html.in
	./tohtml.rb $< > $@

%.shtml: %.hikidoc template.html.in
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
