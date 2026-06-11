.PHONY: install ci

install:
	./install.sh --force

ci:
	./install.sh --force --config config/ci.conf
