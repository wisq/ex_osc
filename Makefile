all: test hooks

hooks:
	cd .git/hooks && ln -nsf ../../deps/ex_git_test/hooks/* ./

test:
	mix test

.PHONY: hooks test
