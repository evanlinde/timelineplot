localbin := /usr/local/bin
bin := /usr/bin
exe := timelineplot

all : doc

.PHONY: doc
doc :
	$(MAKE) -C doc

install :
	install -m 755 $(exe) $(bin)/
	$(MAKE) -C doc install

install-local :
	install -m 755 $(exe) $(localbin)/
	$(MAKE) -C doc install-local

uninstall :
	rm -f $(bin)/$(exe)
	$(MAKE) -C doc uninstall

uninstall-local :
	rm -f $(localbin)/$(exe)
	$(MAKE) -C doc uninstall-local

