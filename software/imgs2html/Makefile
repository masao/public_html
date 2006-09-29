# $Id$

CVSDIR = /home/masao/cvswork/imgs2html
UPDATE_NEWS = ./update_news.pl
POD2HTML = ./mypom2.pl

all: index.html ps2imgs-man.html imgs2html-man.html

index.html: $(CVSDIR)/NEWS $(UPDATE_NEWS)
	$(UPDATE_NEWS)

ps2imgs-man.html: $(CVSDIR)/ps2imgs.in $(POD2HTML)
	$(POD2HTML) "$(CVSDIR)/ps2imgs" > $@

imgs2html-man.html: $(CVSDIR)/imgs2html.in $(POD2HTML)
	$(POD2HTML) "$(CVSDIR)/imgs2html" > $@
