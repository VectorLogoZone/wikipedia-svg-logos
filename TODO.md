# To Do

* switch mediatitles.sh to Python instead of bash
* handle redirected images
* mediatitles - figure out what 'logo' is in each language
* build.sh - take list of languages from env

## InfoBox Scraping

Lots of logos don't have 'logo' in the name.  This is the outline of how to get them from the `infobox` section of a wikipedia page.

### Overall Steps

* Download .bz
* Unpack .bz
* Process each file

### File Processing

* Scan for Infobox
* Get logo svg
* Get website
* Get Article name
* Save (article title, website, logo.svg)

### Tasks

* Figure out how to use the multi-stream versions
