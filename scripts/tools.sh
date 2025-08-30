#!/bin/sh
set -u

# aliases start

alias ls='ls -A -l -h --group-directories-first --full-time'
alias chx='chmod +x'
alias permof='/root/arch/scripts/permof.sh'
alias sizeof='du -sh'
alias grep='grep --color'
alias c='clear'
alias x='exit'
alias sr='screen -r'
alias sn='screen -S'
alias speedtest='wget https://avacyn.radiance.hr/stuff/debian-12.5.0-amd64-netinst.iso -O /dev/null'
alias myip='curl https://avacyn.radiance.hr/ip'

_reset="\[\033[0m\]"
_blue_b="\[\033[1;34m\]"

PS1="\w ${_blue_b}#${_reset} "

# aliases end

_uid="1000"
_gid="1000"
_secret="/root/secret.txt"
_username="$(cat "${_secret}" | sed -n '1p')"
_password="$(cat "${_secret}" | sed -n '2p')"
_public="/root/_public"
_private="/root/_private"

_mount_remote() {
    mount -t cifs -o username="${_username}",password="${_password}",uid="${_uid}",gid="${_gid}",dir_mode=0755,file_mode=0644,port=44555 "${@}"
}

mountall() {
    mkdir -p "${_public}"
    mkdir -p "${_private}"
    _mount_remote "//radiance.hr/public" "${_public}"
    _mount_remote "//radiance.hr/private" "${_private}"
}

zero() {
    if [ -z "${1-}" ] || [ ! -b "${1}" ]
    then
        printf '%s\n' "Usage example: zero /dev/nvme0n1" >&2
        return 1
    fi
    dd if=/dev/zero of="${1}" bs=1M
}

backup() {
    if [ -z "${1-}" ] || [ -z "${2-}" ] || [ ! -b "${1}" ]
    then
        printf '%s\n' "Usage example: backup /dev/nvme0n1 /root/private/backups/win" >&2
        return 1
    fi
    dd if="${1}" conv=sync,noerror bs=64K | gzip -c > "${2}.img.gz"
}

restore() {
    if [ -z "${1-}" ] || [ -z "${2-}" ] || [ ! -b "${2}" ]
    then
        printf '%s\n' "Usage example: restore /root/private/backups/win.img.gz /dev/nvme0n1" >&2
        return 1
    fi
    gunzip -c "${1}" | dd of="${2}"
}
