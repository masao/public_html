ALL=	jsik.pdf jsik.png

all: $(ALL)
clean:
	rm -f $(ALL)

jsik.pdf: jsik.tex jsik.bib jsik.bst
	platex jsik.tex && jbibtex jsik && platex jsik.tex && platex jsik.tex && dvipdfmx jsik

jsik.png: jsik.pdf
	dvips jsik.dvi
	echo "(jsik.ps) run" | gs -q -dNOPAUSE -sDEVICE=ppmraw -sPAPERSIZE=a4 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=jsik.ppm
	convert -trim jsik.ppm jsik.png
