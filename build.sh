#!/bin/bash

#  _                    
# | |__   _____  _____  
# | '_ \ / _ \ \/ / _ \ 
# | | | |  __/>  < (_) |
# |_| |_|\___/_/\_\___/ 

# +-------------------+
# | hexo build script |
# +-------------------+

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

# install hexo if not found
if ! [ command -v hexo &> /dev/null ]; then
	echo -e "${RED}hexo not found${RESET}"
	npm install -g hexo-cli
	npm install
fi

# install/update dependencies
npm install hexo-theme-redefine@latest
npm install hexo-generator-searchdb --save
npm install hexo-wordcount
npm install nodejieba

# build site
echo -e "${GREEN}Building site...${RESET}"
hexo generate
