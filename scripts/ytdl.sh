#!/bin/sh
set -eu
IFS='
'

_echo() {
    printf '\033[91m%s\033[0m\n' "${1}"
}

_src="${HOME}/yt.txt"
_wd="${HOME}/ytdl"

rm -rf "${_wd}"
mkdir -p "${_wd}"

(
    cd "${_wd}"
    _echo "Running yt-dlp for: ${_src}"
    yt-dlp -a "${_src}" -o "%(title)s.%(ext)s" -v --extract-audio --audio-format mp3
    
    _echo "Renaming files in: ${_wd}"
    perl-rename -v 's/[^a-zA-Z0-9]//g; s/mp3$/.mp3/' ./*.mp3
)

# increase volume for Huawei Watch GT 2 Pro
for _mp3 in "${_wd}/"*.mp3
do
    if [ -f "${_mp3}" ]
    then
        _echo "Running ffmpeg for: ${_mp3}"
        ffmpeg -i "${_mp3}" -af 'volume=3' -codec:a libmp3lame -qscale:a 4 "$(dirname "${_mp3}")/yt-$(basename "${_mp3}")"
        rm -v "${_mp3}"
    fi
done
