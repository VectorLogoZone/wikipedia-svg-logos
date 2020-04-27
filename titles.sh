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

DATE=20200426
#$(date -u +%Y%m%d)
MEDIA_DUMP="enwiki-${DATE}-all-media-titles"
MEDIA_DOWNLOAD="https://dumps.wikimedia.org/other/mediatitles/${DATE}/enwiki-${DATE}-all-media-titles.gz"

echo "INFO: Starting titles at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ -f "${MEDIA_DUMP}" ]; then
    echo "INFO: using existing download ${MEDIA_DUMP}"
else
    echo "INFO: downloading ${MEDIA_DOWNLOAD}..."
    curl \
        "${MEDIA_DOWNLOAD}" \
        | gunzip - \
        > "${MEDIA_DUMP}"
fi

echo "INFO: extracting logo svgs"

grep "\.svg$" enwiki-20200426-all-media-titles \
    | grep -i logo \
    | tail -n 10 - \
    >svg_logos.txt

echo "INFO: found $(cat svg_logos.txt | wc -l) svg logos"

echo '{}' \
    | jq '.handle|="wikipedia-titles"' \
    | jq ".lastmodified|=\"$(date -u  +%Y-%m-%dT%H:%M:%SZ)\"" \
    | jq '.name|="Wikipedia Titles"' \
    | jq '.provider|="direct"' \
    | jq '.provider_icon|="https://www.vectorlogo.zone/logos/wikipedia/wikipedia-icon.svg"' \
    | jq '.url|="https://en.wikipedia.org/"' \
    | jq --sort-keys . \
    > metadata.json
#    | jq '.images|=[]' \

echo "INFO: convert text to json"

cat svg_logos.txt \
    | jq --raw-input --slurp 'split("\n") | map(select(. != "")) | map( {img: (.), name: (.[0:-4]), url: ("http://abc/" + .)} )' \
    > svg_logos.json

echo "INFO: merging json array into sourceData"

jq \
    --argjson images "$(<svg_logos.json)" \
    '.images = $images' \
    metadata.json \
    > sourceData.json


#    | jq -R '. | {img: (.), name: (.[0:-4]), url: ("http://abc/" + .)}'
  #"handle": "adamfairhead",
  #"images": []
  #"lastmodified": "2020-04-25 12:28:24",
  #"name": "adamfairhead/webicons",
  #"provider": "github",
  #"provider_icon": "https://www.vectorlogo.zone/logos/github/github-icon.svg",
  #"url": "https://github.com/adamfairhead/webicons"
   

echo "INFO: Finished titles at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
