localman := /usr/local/share/man
localman1 := $(localman)/man1
man := /usr/share/man
man1 := $(man)/man1
exe := timelineplot
manpage := $(exe).1.gz

all : $(manpage) manual.txt

clean : 
	rm -f *.gz manual.txt

install : $(manpage)
	install -m 644 $^ $(man1)/

install-local : $(manpage)
	mkdir -p $(localman1)
	install -Dm 644 $^ $(localman1)/

$(manpage) : $(exe).1
	gzip -c $^ > $@

manual.txt : $(exe).1
	groff -mandoc -T utf8 $^ | col -bx > $@

uninstall :
	rm -f $(man1)/$(manpage)

uninstall-local :
	rm -f $(localman1)/$(manpage)

