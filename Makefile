.PHONY : all deploy

all: deploy

dependencies:
	@if ! command -v hexo > /dev/null; then \
		echo "Installing Hexo..."; \
		npm install hexo-cli -g; \
	fi
	npm install

deploy: dependencies
	@echo "Building site..."
	hexo generate

clean:
	rm -r public
