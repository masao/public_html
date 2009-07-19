all: index.html ping sitemap.xml bicycle-meter.png

index.html: ChangeLog chalow cl.conf ../private/ChangeLog.delicious
	./chalow -q -u -c cl.conf ChangeLog ../private/ChangeLog.delicious

ChangeLog: ../private/ChangeLog cl-grep.pl ChangeLogReader.pm
	./cl-grep.pl ../private/ChangeLog > ChangeLog

ping: index.html
	curl -sS -o ping -X POST -H "Content-Type: text/xml; charset=UTF-8" \
		-d @../private/ping.xml \
		http://rpc.technorati.jp/rpc/ping \
		http://api.my.yahoo.co.jp/RPC2 \
		http://api.my.yahoo.com/RPC2 \
		http://bulkfeeds.net/rpc \
		http://ping.blo.gs/ \
		http://ping.bloggers.jp/rpc/ \
		http://rpc.technorati.com/rpc/ping \
		http://rpc.technorati.jp/rpc/ping \
		http://rpc.weblogs.com/RPC2 \
		http://www.blogpeople.net/servlet/weblogUpdates \
		http://r.hatena.ne.jp/rpc \
		http://www.bloglines.com/ping \
		http://ping.ask.jp/xmlrpc.m \
		http://blog.goo.ne.jp/XMLRPC \
		http://blogsearch.google.co.jp/ping/RPC2 \
		http://rpc.reader.livedoor.com/ping \
		> ping

sitemap.xml: index.html
	./cli2sitemap.pl cl.itemlist > sitemap.xml

bicycle-meter.png: bicycle-meter.txt
	./bicycle-meter-gnuplot.rb $<
bicycle-meter.txt: ChangeLog
	../software/cl2bicycle-meter.pl $< > $@
