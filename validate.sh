#!/bin/bash
#
# validate the json
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: validation starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

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

if ! [ -x "$(command -v ajv)" ]; then
    echo "ERROR: ajv is not installed.  Run 'npm install -g ajv-cli'"
    exit 2
fi

if ! [ -x "$(command -v curl)" ]; then
    echo "ERROR: curl is not installed."
    exit 3
fi

SCHEMA_URL=${SCHEMA_URL:-http://logosear.ch/api/sourceData.schema.json}
SCHEMA_FILE=$(mktemp)
echo "INFO: downloading schema into ${SCHEMA_FILE}"
curl ${SCHEMA_URL} >${SCHEMA_FILE}

DATA_FILES="${OUTPUT_DIR}/*sourceData.json"
for JSON in $DATA_FILES
do
    echo "Processing ${JSON}..."
    ajv validate -s "${SCHEMA_FILE}" -d "${JSON}" 2>&1
done

echo "INFO: validation complete at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

