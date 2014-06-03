
# Version name is "nightly" or a version number
ARG_DEFS=(
  "--version-name=(.*)"
)

function init {
  CDN_DIR=$HOME/ionic-code
  ../clone/clone.sh --repository="driftyco/ionic-code" \
    --directory="$CDN_DIR" \
    --branch="gh-pages"
}

function run {
  cd ../..

  VERSION_DIR=$CDN_DIR/$VERSION_NAME
  VERSION=$(readJsonProp "package.json" "version")

  rm -rf $VERSION_DIR
  mkdir -p $VERSION_DIR
  cp -Rf dist/* $VERSION_DIR

  echo "-- Generating versions.json..."
  cd $CDN_DIR/builder
  python ./generate.py

  cd $CDN_DIR
  git add -A
  git commit -am "release: $VERSION ($VERSION_NAME)"

  git push -q origin gh-pages

  echo "-- Published ionic-code v$VERSION successfully!"
}

source $(dirname $0)/../utils.inc
