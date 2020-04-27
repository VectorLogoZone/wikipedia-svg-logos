https://en.wikipedia.org/wiki/Wikipedia:Database_download#Where_are_the_uploaded_files_(image,_audio,_video,_etc.)?


Hotlinking is allowed!
https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia/technical#Hotlinking

List of all media files:
https://dumps.wikimedia.org/other/mediatitles/20200204/enwiki-20200204-all-media-titles.gz

gunzip ${FILE}

grep -i svg ${FILE} | grep -i logo
15K logos

Page on wikipedia:
https://en.wikipedia.org/wiki/File:Zain_Group_logo.svg
https://upload.wikimedia.org/wikipedia/en/5/5c/Zain_Group_logo.svg

https://en.wikipedia.org/wiki/File:YHA_Australia_logo.svg
https://upload.wikimedia.org/wikipedia/en/8/81/YHA_Australia_logo.svg

https://github.com/TannerBaldus/wp/blob/master/wp_image.py

https://en.wikipedia.org/wiki/File:École_des_Mines_de_Douai.svg
https://upload.wikimedia.org/wikipedia/en/5/5e/%C3%89cole_des_Mines_de_Douai.svg

https://upload.wikimedia.org/wikipedia/en/

Downloads:
https://dumps.wikimedia.org/enwiki/20200120/
image metadata? enwiki-20200120-image.sql.gz

https://dumps.wikimedia.org/wikidatawiki/20200120/wikidatawiki-20200120-pages-articles.xml.bz2

Calculating the image hash directories:
https://stackoverflow.com/questions/13638579/how-to-construct-full-url-from-wikipedia-file-tag-in-wikimedia-markup

https://upload.wikimedia.org/wikipedia/en/1/19/007_logo.svg
echo -n "007_logo.svg" | md5sum | cut -c 1-2


## Update process flow

- stream download
