index.html: ChangeLog chalow cl.conf
	./chalow -q -c cl.conf ChangeLog

ChangeLog: ../private/ChangeLog cl-grep.pl ChangeLogReader.pm
	./cl-grep.pl ../private/ChangeLog > ChangeLog
