#!/bin/bash

ARG_DEFS=(
  "--build-number=(.*)"
)

function run {
  cd ../..

  OLD_VERSION=$(readJsonProp "package.json" "version")
  NIGHTLY_VERSION="$OLD_VERSION-nightly-$BUILD_NUMBER"

  replaceJsonProp "package.json" "version" "$NIGHTLY_VERSION"

  gulp build --release
  gulp changelog --standalone \
    --html=true \
    --subtitle="(changes since $OLD_VERSION)" \
    --dest="dist/CHANGELOG.html" \
    --from="$(git tag | grep $OLD_VERSION)"

  echo "-- Nightly Version: $NIGHTLY_VERSION"
}

source $(dirname $0)/../utils.inc
