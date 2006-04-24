all: index.html

ChangeLog: ../private/ChangeLog
	./cl-grep.pl $< > ChangeLog

index.html: ChangeLog
	./chalow -q -c cl.conf $<
