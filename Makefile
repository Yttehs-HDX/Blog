.PHONY : all deploy

GREEN='\033[0;32m'
RESET='\033[0m'

all: deploy

dependencies:
	npm install -g hexo-cli
	npm install
	npm install hexo-theme-redefine@latest
	npm install hexo-generator-searchdb --save
	npm install hexo-wordcount
	npm install nodejieba
	npm install hexo-all-minifier

deploy: dependencies
	@echo "$(GREEN)Building site...$(RESET)"
	hexo generate
