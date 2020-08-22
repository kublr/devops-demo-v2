#!/bin/sh

BASEDIR=$(dirname $(realpath "$0"))

. "${BASEDIR}/../main.properties"

COMPONENT_VERSION="${COMPONENT_VERSION:-0.0.0}"
BUILD_NUMBER="${BUILD_NUMBER:-0}"

# GIT_BRANCH is the git branch name, "detached", or "nogit"
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD || echo nogit)"
GIT_BRANCH="${GIT_BRANCH:-detached}"

# GIT_BRANCH_ID is an identifier based on the branch name
GIT_BRANCH_ID="$(echo "${GIT_BRANCH}" | tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]')"

# GIT_HASH is 8 char git hash, "nohash", or "nogit"
GIT_HASH="$(git rev-parse --short=8 HEAD || echo nogit)"
GIT_HASH="${GIT_HASH:-nohash}"

# GIT_STATUS is one of "nogit", "clean", "dirty"
GIT_STATUS="$(git status -s || echo nogit)"
if [ "${GIT_STATUS}" != "nogit" ] ; then
  if [ -n "${GIT_STATUS}" ] ; then
    GIT_STATUS=dirty
  else
    GIT_STATUS=clean
  fi
fi

# TAG is $(COMPONENT_VERSION) for release branches, or
#        $(COMPONENT_VERSION)-$(GIT_BRANCH_ID).$(BUILD_NUMBER).$(GIT_HASH).$(GIT_STATUS) for non-release brances
case "${GIT_BRANCH}" in
  master|release*)
    RELEASE_BRANCH=1
    TAG="${COMPONENT_VERSION}"
    ;;
  *)
    RELEASE_BRANCH=""
    TAG="${COMPONENT_VERSION}-${GIT_BRANCH_ID}.${BUILD_NUMBER}.${GIT_HASH}.${GIT_STATUS}"
    ;;
esac

echo "COMPONENT_VERSION=${COMPONENT_VERSION}"
echo "BUILD_NUMBER=${BUILD_NUMBER}"
echo "GIT_BRANCH=${GIT_BRANCH}"
echo "GIT_BRANCH_ID=${GIT_BRANCH_ID}"
echo "GIT_HASH=${GIT_HASH}"
echo "GIT_STATUS=${GIT_STATUS}"
echo "RELEASE_BRANCH=${RELEASE_BRANCH}"
echo "TAG=${TAG}"
