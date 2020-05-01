#!/usr/bin/env bash
#
# get all svg from wikipedia with 'logo' in the filename
#
# for reference, on 2020-04-26:
# download was 9,105,764 bytes
# dump (un-gzipped) is 25,128,303 bytes
# dump had 917095 lines
# 28701 svgs
# 16,265 with logo in the name

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: Starting titles at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

LANG=${1:-BAD}
if [ "${LANG}" == "BAD" ]; then
    echo "usage: titles.sh language [date]"
    exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
    echo "ERROR: jq is not installed."
    exit 2
fi

if ! [ -x "$(command -v curl)" ]; then
    echo "ERROR: curl is not installed."
    exit 3
fi

#
# load an .env file if it exists
#
ENV_FILE=".env"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading '${ENV_FILE}'"
    export $(cat "${ENV_FILE}")
fi

TODAY=$(date -u +%Y%m%d)
DATE=${DATE:-$TODAY}
OUTPUT_DIR=${OUTPUT_DIR:-./output}
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "INFO: creating output directory ${OUTPUT_DIR}"
    mkdir -p "${OUTPUT_DIR}"
fi

TMP_DIR=${TMP_DIR:-./tmp}
if [ ! -d "${TMP_DIR}" ]; then
    echo "INFO: creating output directory ${TMP_DIR}"
    mkdir -p "${TMP_DIR}"
fi

MEDIA_DUMP="${LANG}wiki-${DATE}-all-media-titles"

if [ -f "${TMP_DIR}/${MEDIA_DUMP}" ]; then
    echo "INFO: using existing download ${MEDIA_DUMP}"
else
    MEDIA_DOWNLOAD="https://dumps.wikimedia.org/other/mediatitles/${DATE}/${LANG}wiki-${DATE}-all-media-titles.gz"
    echo "INFO: downloading ${MEDIA_DOWNLOAD}..."
    curl \
        "${MEDIA_DOWNLOAD}" \
        | gunzip - \
        > "${TMP_DIR}/${MEDIA_DUMP}"
fi

echo "INFO: extracting logo svgs"

grep "\.svg$" "${TMP_DIR}/${MEDIA_DUMP}" \
    | grep -i logo \
    >"${TMP_DIR}/${LANG}-svg-logos.txt"
#    | tail -n 10 - \

echo "INFO: found $(cat "${TMP_DIR}/${LANG}-svg-logos.txt" | wc -l) svg logos"

echo '{}' \
    | jq ".data.description|=\"SVG files on the ${LANG} Wikipedia with logo in the name\"" \
    | jq ".handle|=\"wikipedia-mediatitles-${LANG}\"" \
    | jq ".lastmodified|=\"$(date -u  +%Y-%m-%dT%H:%M:%SZ)\"" \
    | jq '.logo|="https://www.vectorlogo.zone/logos/wikipedia/wikipedia-icon.svg"' \
    | jq ".name|=\"Wikipedia ${LANG} mediatitles\"" \
    | jq '.provider|="remote"' \
    | jq '.provider_icon|="https://logosear.ch/images/remote.svg"' \
    | jq '.url|="https://en.wikipedia.org/"' \
    | jq --sort-keys . \
    > "${TMP_DIR}/${LANG}-metadata.json"

echo "INFO: converting text to json"

#LATER: this would be faster with a custom program instead of exec'ing md5sum once per line...
cat "${TMP_DIR}/${LANG}-svg-logos.txt" \
    | while read -r line; do
        echo "$(printf %s "$line" | md5sum | cut -c 1-2),$line"
    done \
    | jq --raw-input --slurp "split(\"\\n\") | map(select(. != \"\")) | map( {img: (\"https://upload.wikimedia.org/wikipedia/${LANG}/\" + .[0:1] + \"/\" + .[0:2] + \"/\" + .[3:]), name: (.[3:-4]), src: (\"https://${LANG}.wikipedia.org/wiki/File:\" + .[3:])} )" \
    > "${TMP_DIR}/${LANG}-svg-logos.json"

echo "INFO: merging json array into sourceData"

jq --sort-keys \
    '.images += input' \
    "${TMP_DIR}/${LANG}-metadata.json" \
    "${TMP_DIR}/${LANG}-svg-logos.json" \
    >"${OUTPUT_DIR}/${LANG}-mediatitle-sourceData.json"

#    | jq -R '. | {img: (.), name: (.[0:-4]), url: ("http://abc/" + .)}'
  #"handle": "adamfairhead",
  #"images": []
  #"lastmodified": "2020-04-25 12:28:24",
  #"name": "adamfairhead/webicons",
  #"provider": "github",
  #"provider_icon": "https://www.vectorlogo.zone/logos/github/github-icon.svg",
  #"url": "https://github.com/adamfairhead/webicons"
   

echo "INFO: Finished mediatitles for ${LANG} at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
