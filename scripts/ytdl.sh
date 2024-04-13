#!/bin/sh
set -eu
IFS='
'

_echo() {
    printf '\033[91m%s\033[0m\n' "${1}"
}

_src="${HOME}/ytdl.txt"
_wd="${HOME}/ytdl-tmp"
_dest="${HOME}/ytdl"

rm -vrf "${_wd}"
mkdir -vp "${_wd}"
mkdir -vp "${_dest}"

(
    cd "${_wd}"
    _echo "Running yt-dlp for: ${_src}"
    yt-dlp -a "${_src}" -o "%(title)s.%(ext)s" -v --extract-audio --audio-format mp3
    
    _echo "Renaming files in: ${_wd}"
    perl-rename -v 's/[^a-zA-Z0-9]//g; s/mp3$/.mp3/' ./*.mp3
    
    # increase volume for Huawei Watch GT 2 Pro
    for _mp3 in *.mp3
    do
        if [ -f "${_mp3}" ]
        then
            _echo "Running ffmpeg for: ${_mp3}"
            _prod="yt-$(basename "${_mp3}")"
            ffmpeg -i "${_mp3}" -af 'volume=3' -codec:a libmp3lame -qscale:a 4 "${_prod}"
            mv -v "${_prod}" "${_dest}"
            rm -v "${_mp3}"
        fi
    done
)

# remove working dir
rm -vrf "${_wd}"