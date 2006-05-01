index.html: ChangeLog chalow cl.conf ../private/ChangeLog.delicious
	./chalow -q -c cl.conf ChangeLog ../private/ChangeLog.delicious

ChangeLog: ../private/ChangeLog cl-grep.pl ChangeLogReader.pm
	./cl-grep.pl ../private/ChangeLog > ChangeLog
