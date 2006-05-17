# $Id$
#

HTML	= index.html profile.html history.html
SUBDIR	= etc

all: $(HTML) chalow subdirs

subdirs:
	for d in $(SUBDIR); do \
		cd $$d/ && make;\
	done

%.html: %.html.in template.html.in tohtml.rb
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
