.PHONY : all deploy

all: deploy

dependencies:
	@if ! command -v hexo > /dev/null; then \
		echo "Installing Hexo..."; \
		npm install hexo-cli -g; \
	fi
	npm install
	npm install hexo-theme-redefine@latest
	npm install hexo-generator-searchdb --save
	npm install hexo-wordcount
	npm install nodejieba@2.5.1
	npm install hexo-all-minifier

deploy: dependencies
	@echo "Building site..."
	hexo generate

clean:
	rm -r public
