NAME=treerepl
VERSION=0.0.1
DATE=$(shell date +"%Y-%m-%d")

.PHONY: test

%.gemspec:%.gemspec.in
	cat $< | sed \
		-e 's/%NAME%/$(NAME)/g' \
		-e 's/%DATE%/$(DATE)/g' \
		-e 's/%VERSION%/$(VERSION)/g' \
		> $@

$(NAME)-$(VERSION).gem: $(NAME).gemspec rdoc
	gem build $<

all: $(NAME)-$(VERSION).gem

push: $(NAME)-$(VERSION).gem
	gem push $<

install: $(NAME)-$(VERSION).gem
	sudo gem install $<

rdoc:
	rdoc --title "Tree Repl"

test:
	ruby test/suite.rb

tests:
	chmod +x $(NAME)
	./$(NAME) test/logfile.txt

clean:
	rm -f `find . -name "*~"` $(NAME).gemspec $(NAME)-*.gem

docclean:
	rm -rf doc

allclean: docclean clean