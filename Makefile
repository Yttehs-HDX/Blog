.PHONY : all deploy

all: deploy

dependencies:
	npm install
	npm install hexo-theme-redefine@latest
	npm install hexo-generator-searchdb --save
	npm install hexo-wordcount
	npm install nodejieba
	npm install hexo-all-minifier

deploy: dependencies
	@echo "Building site..."
	hexo generate
