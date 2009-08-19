# $Id$

HTML	= 	index.html.ja index.html.en \
		profile.html.ja profile.html.en \
		profile-images.html.ja profile-images.html.en \
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
		etc/senkyo-koho/index.html \
		etc/senkyo-koho/200907-tokyo/Adachi/index.html \
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
		software/pukiwiki.html \
		software/jsik_bst/index.html \
		private/memo.html \
		private/nims_memo.html \
		lecture/index.html \
		lecture/2005/excel/index.html \
		lecture/2005/html/index.html \
		lecture/2007/kiso/index.html \
		trans/index.html \
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

profile.html.ja: pub/pub.xml
profile.html.en: pub/pub.xml

# chalow
chalow:
	cd private/ && make
	cd d/ && make

# Rsync to http://masao.jpn.org/
## Changed for kaede (2009-05-12)
rsync-on-kaede:
	./rsync.pl etk2:www/masao/d/bbs/kblog/ ./d/bbs/kblog/
	./rsync.pl ./d/bbs/kblog/ arno:public_html/d/bbs/kblog/
	./rsync.pl arno:public_html/ ./
	./rsync.pl --exclude=test/ --exclude=private/ --exclude=official/ \
		--delete-after --copy-unsafe-links \
		./ etk2:www/masao/

#	% make lint
#	% sort -nr score | less
lint:
	./htmllint-all.rb

target:
	@echo $(HTML)
