BASE= ../
HTML= firefox.html

all: $(HTML)

%.html: %.html.in $(BASE)/template.html.in $(BASE)/tohtml.rb
	$(BASE)/tohtml.rb --basedir=.. $< > $@
