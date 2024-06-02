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
npm install -g hexo-cli
npm install

# install/update dependencies
npm install hexo-theme-redefine@latest
npm install hexo-generator-searchdb --save
npm install hexo-wordcount
npm install nodejieba
npm install hexo-all-minifier

# build site
echo -e "${GREEN}Building site...${RESET}"
hexo generate
