all: index.html ping

index.html: ChangeLog chalow cl.conf ../private/ChangeLog.delicious
	./chalow -q -c cl.conf ChangeLog ../private/ChangeLog.delicious

ChangeLog: ../private/ChangeLog cl-grep.pl ChangeLogReader.pm
	./cl-grep.pl ../private/ChangeLog > ChangeLog

ping: index.html
	curl -sS -o ping -X POST -H "Content-Type: text/xml; charset=UTF8" \
		-d @../private/ping.xml \
		http://rpc.technorati.jp/rpc/ping \
		http://api.my.yahoo.co.jp/RPC2 \
		http://api.my.yahoo.com/RPC2 \
		http://bulkfeeds.net/rpc \
		http://ping.blo.gs/ \
		http://ping.bloggers.jp/rpc/ \
		http://ping.cocolog-nifty.com/xmlrpc \
		http://rpc.blogrolling.com/pinger/ \
		http://rpc.technorati.com/rpc/ping \
		http://rpc.technorati.jp/rpc/ping \
		http://rpc.weblogs.com/RPC2 \
		http://www.blogpeople.net/servlet/weblogUpdates > .ping
