ALL=	jsik.pdf jsik.png

all: $(ALL)
clean:
	rm -f $(ALL)

jsik.pdf: jsik.tex jsik.bib jsik.bst
	platex jsik && jbibtex jsik && platex jsik && platex jsik && dvipdfmx jsik

jsik.png: jsik.pdf
	dvips jsik.dvi
	echo "(jsik.ps) run" | gs -q -dNOPAUSE -sDEVICE=ppmraw -sPAPERSIZE=a4 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=jsik.ppm
	convert -trim jsik.ppm jsik.png

test: jsik_test.tex jsik_test.bib jsik.bib jsik.bst
	platex jsik_test && jbibtex jsik_test && platex jsik_test && platex jsik_test && xdvi jsik_test
