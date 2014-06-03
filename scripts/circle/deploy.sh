#!/bin/bash

ARG_DEFS=(
  "[--is-release=(true|false)]"
)

function run {
  export GIT_PUSH_DRYRUN=true
  export VERBOSE=true

  cd ../..

  if [[ "$IS_RELEASE" == "true" ]]; then
    ./scripts/bump/release.sh
    VERSION_NAME=$(readJsonProp "package.json" "version")
  else
    ./scripts/bump/nightly.sh --build-number=${CIRCLE_BUILD_NUM:-$RANDOM}
    VERSION_NAME="nightly"
  fi

  case $CIRCLE_NODE_INDEX in
  0)
    # Push release to ionic repo: release only
    if [[ "$IS_RELEASE" == "true" ]]; then
      ./scripts/release/publish.sh
      gulp release-tweet
      gulp release-irc
    fi
    ;;
  1)
    # Update site config: release only
    if [[ "$IS_RELEASE" == "true" ]]; then
      ./scripts/site/publish.sh --action="updateConfig"
    fi
    ;;
  2)
    # Update app-base: release only
    if [[ "$IS_RELEASE" == "true" ]]; then
      ./scripts/app-base/publish.sh
    fi
    ;;
  3)
    # Update docs
    ./scripts/site/publish.sh --action="docs" --version-name="$VERSION_NAME"
    # Update demos
    ./scripts/demo/publish.sh --version-name="$VERSION_NAME"
    ;;
  4)
    # Update cdn
    ./scripts/cdn/publish.sh --version-name="$VERSION_NAME"
    ;;
  5)
    # Update bower
    ./scripts/bower/publish.sh
    ;;
  esac
}

source $(dirname $0)/../utils.inc
