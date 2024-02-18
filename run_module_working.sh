#!/bin/bash
cd "$(dirname "$0")"

pushd module-lib || exit 1

bash install.sh

popd || exit 1

pushd module-exe || exit 1

bash build-and-run.sh

popd || exit 1
