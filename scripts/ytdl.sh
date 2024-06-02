#!/bin/sh
set -eu
IFS='
'

_echo() {
    printf '\033[91m%s\033[0m\n' "${1}"
}

_date="$(date +%d%m%Y)"
_src="${HOME}/ytdl.txt"
_wd="${HOME}/ytdl-tmp"
_dest="${HOME}/ytdl"
_end="${HOME}/arch/misc/ding.opus"

rm -vrf "${_wd}"
mkdir -vp "${_wd}"
mkdir -vp "${_dest}"

(
    cd "${_wd}"
    _echo "Running yt-dlp for: ${_src}"
    
    # youtube videos are (mostly?) in opus, so download native audio without re-encoding
    yt-dlp -a "${_src}" -o "%(title)s.%(ext)s" -v --extract-audio --audio-format opus
    
    # clean up weird characters in file names
    _echo "Renaming files in: ${_wd}"
    perl-rename -v 's/[^a-zA-Z0-9](?![^.]*$)//g' ./*.opus
    
    # increase volume for Huawei Watch GT 2 Pro
    for _original in ./*.opus
    do
        if [ -f "${_original}" ]
        then
            _basename="$(basename "${_original}")"
            _mp3="yt${_date}-${_basename%%.*}.mp3"
            _echo "Converting ${_original} to ${_mp3}"
            ffmpeg -i "concat:${_original}|${_end}" -af 'volume=3' -codec:a libmp3lame -qscale:a 4 "${_mp3}"
            mv -v "${_mp3}" "${_dest}"
            rm -v "${_original}"
        fi
    done
)

# remove working dir
rm -vrf "${_wd}"