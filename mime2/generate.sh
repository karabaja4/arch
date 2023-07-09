#!/bin/sh

_dir="$(dirname "$(readlink -f "${0}")")"
_path="${_dir}/mimeapps.list"

_echo() {
    printf '%s\n' "${1}"
}

rm -f "${_path}"
{
    cut -d':' -f1 "/usr/share/mime/globs"
    cut -d' ' -f1 "/usr/share/mime/aliases"
    cut -d' ' -f2 "/usr/share/mime/aliases"
    cat "/usr/share/mime/types"
} >> "${_path}"
rm -rf "${_dir}/media-types.xml"
wget "https://www.iana.org/assignments/media-types/media-types.xml"
{
    grep -oP '(?<=<file type="template">).*(?=</file>)' "${_dir}/media-types.xml"
    grep "<mime-type type=" "/usr/share/mime/packages/freedesktop.org.xml" | cut -d'"' -f2
    _echo "x-scheme-handler/http"
    _echo "x-scheme-handler/https"
}  >> "${_path}"
sort -u -o "${_path}" "${_path}"
sed -e 's/$/=mime2.desktop/' -i "${_path}"
sed -i '1s/^/[Default Applications]\n/' "${_path}"
sed -i '/^#/d' "${_path}"
chmod 400 "${_path}"

ln -sfv "${_path}" "${HOME}/.config/mimeapps.list"
ln -sfv "${_path}" "${HOME}/.local/share/applications/mimeapps.list"
