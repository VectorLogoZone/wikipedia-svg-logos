#!/bin/bash
#
# run locally for dev
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: Starting dev server at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

#
# load an .env file if it exists
#
ENV_FILE="${1:-./.env}"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

OUTPUT_DIR=${OUTPUT_DIR:-./output}
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "INFO: output directory ${OUTPUT_DIR} does not exist. Run mediatitles.sh a few times first!"
    exit 1
fi

BUILD_DIR=${BUILD_DIR:-./build}
if [ ! -d "${BUILD_DIR}" ]; then
    echo "INFO: creating build directory ${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
fi

#
# make the index
#
echo "INFO: building index"
tar cvzf ${BUILD_DIR}/sourceData.tgz \
	${OUTPUT_DIR}/*sourceData.json

#
# friendly exit message
#
function cleanup()
{
    echo "INFO: Shutting down dev server at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    exit 0
}
trap cleanup EXIT

#
# serve it
#
BIND=${BIND:-127.0.0.1}
PORT=${PORT:-4001}
echo "INFO: serving on ${BIND}:${PORT}.  Use Ctrl-C to exit"
python3 -m http.server ${PORT} \
    --bind "${BIND}" \
    --directory "${BUILD_DIR}"
