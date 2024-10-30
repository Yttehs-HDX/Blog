.PHONY : all deploy

SHELL := /bin/bash

all: deploy

deploy:
	@$(SHELL) .scripts/build.sh
