# $Id$

HTML	= 	index.html profile.html history.html links.html \
		etc/index.shtml \
		etc/firefox.html \
		etc/ir-journal.html \
		etc/unihan-onkun.html \
		etc/wikiwiki.html \
		etc/emacs20-unicode.html \
		etc/paper-checklist.html \
		etc/rpm.html \
		etc/config.html \
		etc/windows-software.html \
		software/index.html \
		software/mnewsprint/index.html \
		software/imgs2html/index.html \
		software/yim/index.html \
		software/zipcode_cgi.html \
		software/graphviz-ja/index.html \

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
	./rsync.pl etk:www/masao/d/bbs/kblog/ ./d/bbs/kblog/
	./rsync.pl --exclude=test/ --exclude=private/ \
		./ etk:www/masao/

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb
