localman := /usr/local/share/man
localman1 := $(localman)/man1
man := /usr/share/man
man1 := $(man)/man1
exe := timelineplot
manpage := $(exe).1.gz

all : $(manpage)

clean : 
	rm -f *.gz

install : $(manpage)
	install -m 644 $^ $(man1)/

install-local : $(manpage)
	mkdir -p $(localman1)
	install -Dm 644 $^ $(localman1)/

$(manpage) : $(exe).1
	gzip -c $^ > $@

uninstall :
	rm -f $(man1)/$(manpage)

uninstall-local :
	rm -f $(localman1)/$(manpage)

