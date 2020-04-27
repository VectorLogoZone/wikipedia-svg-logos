#!/bin/bash
#
# validate the json
#
set -o errexit
set -o pipefail
set -o nounset


#LATER: check if ajv exists
#npm install -g ajv-cli

ajv validate -s searchData.schema.json -d "sourceData.json" 2>&1 >foo

