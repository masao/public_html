all: index.html ping

index.html: ChangeLog chalow cl.conf ../private/ChangeLog.delicious
	./chalow -q -c cl.conf ChangeLog ../private/ChangeLog.delicious

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
		http://rpc.bloglines.com/update \
		http://ping.ask.jp/xmlrpc.m \
		http://blog.goo.ne.jp/XMLRPC \
		http://blogsearch.google.co.jp/ping/RPC2 \
		> ping
