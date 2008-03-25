# $Id$

HTML	= 	index.html.ja index.html.en \
		profile.html.ja profile.html.en \
		history.html links.html \
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
		namazu/index.html \
		software/index.html \
		software/mnewsprint/index.html \
		software/imgs2html/index.html \
		software/yim/index.html \
		software/msimpleform/index.html \
		software/zipcode_cgi.html \
		software/graphviz-ja/index.html \
		software/google-cache.html \
		software/jmarcfilter/index.html \
		private/memo.html \
		lecture/index.html \
		lecture/2005/excel/index.html \
		lecture/2005/html/index.html \
		lecture/2007/kiso/index.html \
		trans/2008/index.html \
		trans/2008/wikipedia_community_publishing.html \

TOHTML =	./tohtml.rb
TOHTML_JA=$(TOHTML) ./tohtml.conf.ja ./template.html.ja
TOHTML_EN=$(TOHTML) ./tohtml.conf.en ./template.html.en

all: $(HTML) chalow

%.html: %.hikidoc $(TOHTML_JA)
	./tohtml.rb $< > $@

%.shtml: %.hikidoc $(TOHTML_JA)
	./tohtml.rb $< > $@

%.html.ja: %.hikidoc.ja $(TOHTML_JA)
	./tohtml.rb $< > $@

%.html.en: %.hikidoc.en $(TOHTML_EN)
	./tohtml.rb $< > $@

# chalow
chalow:
	cd private/ && make
	cd d/ && make

# Rsync to http://masao.jpn.org/
rsync:
	./rsync.pl etk:www/masao/d/bbs/kblog/ ./d/bbs/kblog/
	./rsync.pl --exclude=test/ --exclude=private/ --delete-after \
		./ etk:www/masao/

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb

target:
	@echo $(HTML)
