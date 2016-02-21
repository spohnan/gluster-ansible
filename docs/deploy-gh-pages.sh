#!/usr/bin/env sh
#
# Push finished pages into gh-pages branch of the project
#

cd docs/target/gh-pages/
git init
git config user.name "Travis-CI"
git config user.email "travis-ci@andyspohn.com"
git add .
git commit -m "Deploy to GitHub Pages"
git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1