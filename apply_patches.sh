#!/bin/bash
set -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd $DIR/../linux
git checkout -f fbc56042a9cfa37f9003665fe48d8b68dc3e8491
git am $DIR/patches/host-linux/*.patch

cd $DIR/../linux-guest
git checkout -f fbc56042a9cfa37f9003665fe48d8b68dc3e8491
git am $DIR/patches/guest-linux/*.patch
