all: test hooks

hooks:
	cd .git/hooks && ln -nsf ../../hooks/* ./

test:
	mix test

.PHONY: hooks test
