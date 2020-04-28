#!/bin/bash
#
# run locally for dev
#

set -o errexit
set -o pipefail
set -o nounset

#
# load an .env file if it exists
#
ENV_FILE="${1:-./.env}"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

OUTPUT_DIR=${OUTPUT_DIR:-./tmp}

#
# make the index
#
echo "INFO: building index"
tar cvzf ${OUTPUT_DIR}/sourceData.tgz \
	./sourceData.json

#
# serve it
#
BIND=${BIND:-127.0.0.1}
PORT=${PORT:-4001}
echo "INFO: serving on ${BIND}:${PORT}"
python3 -m http.server ${PORT} \
    --bind "${BIND}" \
    --directory "${OUTPUT_DIR}"
