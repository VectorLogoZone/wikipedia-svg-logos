#!/bin/bash
#
# build .tgz for a release
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: Starting build at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

#
# load an .env file if it exists
#
ENV_FILE="${1:-./.env}"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

./mediatitles.sh commons
./mediatitles.sh de
./mediatitles.sh en
./mediatitles.sh fr
./mediatitles.sh it

BUILD_DIR=${BUILD_DIR:-./build}
if [ ! -d "${BUILD_DIR}" ]; then
    echo "INFO: creating build directory ${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
fi

OUTPUT_DIR=${OUTPUT_DIR:-./output}
#
# make the index
#
echo "INFO: building index from files is ${OUTPUT_DIR}"
tar cvzf ${BUILD_DIR}/sourceData.tgz \
	${OUTPUT_DIR}/*sourceData.json


echo "INFO: finished build at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
