NAMAZU_DIR = /home/masao/Namazu/ipc-search

HEAD = $(NAMAZU_DIR)/NMZ.head.ja
BODY = body.txt
FOOT = $(NAMAZU_DIR)/NMZ.foot.ja

index.html: $(HEAD) $(BODY) $(FOOT)
	cat $(HEAD) $(BODY) $(FOOT) > $@
