#!/bin/bash

declare dir="$(dirname $(readlink -f $0))"
declare path="$dir/mimeapps.list"

rm -f "$path"
cat /usr/share/mime/globs | cut -d':' -f 1 >> "$path"
cat /usr/share/mime/aliases | cut -d' ' -f 1 >> "$path"
cat /usr/share/mime/aliases | cut -d' ' -f 2 >> "$path"
cat /usr/share/mime/types >> "$path"
sort -u -o "$path" "$path"
sed -e 's/$/=mymime.desktop;/' -i "$path"
sed -i '1s/^/[Default Applications]\n/' "$path"
sed -i '/^#/d' "$path"
chmod 400 $path