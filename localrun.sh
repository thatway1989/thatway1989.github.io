#########################################################################
# File Name: localrun.sh
# Author: thatway
# mail: xxx@126.com
# Created Time: 2024年12月10日 星期二 16时08分34秒
#########################################################################
#!/bin/bash

pipenv run mkdocs build
cd _site_mkdocs
pipenv run python -m http.server 8080
cd ..
