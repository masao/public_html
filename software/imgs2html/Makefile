# $Id$

CVSDIR = /home/masao/CVSwork/imgs2html
UPDATE_NEWS = ./update_news.pl

all: index.html ps2imgs-man.html imgs2html-man.html

index.html: $(CVSDIR)/NEWS $(UPDATE_NEWS)
	$(UPDATE_NEWS)

ps2imgs-man.html: $(CVSDIR)/ps2imgs.in
	pod2html --noindex "$(CVSDIR)/ps2imgs" > $@

imgs2html-man.html: $(CVSDIR)/imgs2html.in
	pod2html --noindex "$(CVSDIR)/imgs2html" > $@
