#!/bin/sh

echo "Deploying blog post"
git add .
git commit -am "WIP"
git push
cd resources/public &&  git add . && git commit -am "WIP" && git push && cd ../../
open http://anthontaylor.github.io
