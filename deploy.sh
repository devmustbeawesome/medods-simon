#!/usr/bin/env sh
echo "deploying..."
set -e
npx vite build --base=/medods-simon/
cd dist
git init
git add -A
git commit -m 'deploy'

git push -f git@github.com:devmustbeawesome/medods-simon.git master:gh-pages

cd -