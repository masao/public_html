CVSDIR	= $(HOME)/CVSwork/p-album

FOOTER = footer.html

index.html: $(CVSDIR)/README $(FOOTER) Makefile
	rd2 -r rd/rd2html-lib -r rd/rd2html-opt \
		--with-part=include:include \
		--with-css="../../default.css" \
		--html-charset="EUC-JP" --html-lang="ja" \
		--html-title="p-album" \
		$(CVSDIR)/README $(FOOTER) > $@
