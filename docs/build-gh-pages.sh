#!/usr/bin/env sh
#
# Create documentation and stage for a later push into gh-pages deploy
#

cd docs
mvn clean package
mkdir -p target/gh-pages
cp -r target/generated-docs/* target/gh-pages
rm -f target/gh-pages/*.pdf