.PHONY : all deploy dependencies deploy preview clean

all: deploy

dependencies:
	npm ci

deploy: dependencies
	@echo "Building site..."
	npm run build

preview:
	@echo "Starting server..."
	npm run server

clean:
	rm -rf public
