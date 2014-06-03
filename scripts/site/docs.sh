#!/bin/bash

ARG_DEFS=(
  "--version-name=(.*)"
)

function init {
  SITE_DIR=$HOME/ionic-site

  ../clone/clone.sh --repository="driftyco/ionic-site" \
    --directory="$SITE_DIR" \
    --branch="gh-pages"
}

# Example: ./scripts/site/publish.sh --action=docs --version-name=nightly
function run {

  cd ../..
  VERSION=$(readJsonProp "package.json" "version")

  gulp docs --doc-version="$VERSION_NAME" --dist=$SITE_DIR
  gulp docs-index

  cp -Rf dist/ionic-site/* $SITE_DIR
  cd $SITE_DIR

  DOCS_CHANGES=$(git status --porcelain)

  # if no changes, don't commit
  if [[ "$DOCS_CHANGES" == "" ]]; then
    echo "-- No changes detected in docs for $VERSION_NAME; docs not updated."
  else
    git add -A
    git commit -am "docs: update for $VERSION"
    git push -q origin gh-pages

    echo "-- Updated docs for $VERSION_NAME succesfully!"
  fi
}

source $(dirname $0)/../utils.inc
