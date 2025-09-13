#!/bin/sh
set -e

# speaker-test -D hdmi:CARD=NVidia,DEV=0 -c 2 -t wav

_handle_signal() {
    printf '\n%s\n' 'No choice has been made, goodbye.'
    exit 1
}

trap _handle_signal HUP INT QUIT TERM

_aplay_empty_home="/tmp/aplay-empty-home"
rm -rf "${_aplay_empty_home}"
mkdir -p "${_aplay_empty_home}"

_aplay_default() {
    HOME="${_aplay_empty_home}" aplay -l
}

_aplay="$(_aplay_default | grep '^card ')"

_asoundrc_path="${HOME}/.asoundrc"
_asoundrc_content=''

if [ -f "${_asoundrc_path}" ]
then
    _asoundrc_content="$(cat "${_asoundrc_path}")"
fi

# read current indexes from asoundrc and try to match them up to aplay
_current_index=''
if [ -n "${_asoundrc_content}" ]
then
    _current_card="$(printf '%s\n' "${_asoundrc_content}" | grep '^defaults.pcm.card' | awk '{print $NF}')"
    _current_device="$(printf '%s\n' "${_asoundrc_content}" | grep '^defaults.pcm.device' | awk '{print $NF}')"
    if [ -n "${_current_card}" ] && [ -n "${_current_device}" ]
    then
        _current_index="$(printf '%s\n' "${_aplay}" | grep -n "card ${_current_card}:.*device ${_current_device}:" | cut -d: -f1)"
    fi
fi

_choices="$(printf '%s\n' "${_aplay}" | awk -F'[][]' '{print $2 " - " $4}' | nl -w1 -s ') ')"

if [ "${1}" = "l" ] || [ "${1}" = "-l" ] || [ -z "${1}" ]
then
    # print the numbered list only in list mode or select mode
    # color the line that matched
    if [ -n "${_current_index}" ]
    then
        _color_red="$(printf '\033[94m')"
        _color_reset="$(printf '\033[0m')"
        printf '%s\n' "${_choices}" | sed "${_current_index}s/^/${_color_red}/;${_current_index}s/\$/${_color_reset}/"
    else
        printf '%s\n' "${_choices}"
    fi
fi

# list mode, exit
if [ "${1}" = "l" ] || [ "${1}" = "-l" ]
then
    exit 0
fi

_ln=''
if [ -z "${1}" ]
then
    while [ -z "${_ln}" ] || ! printf '%s\n' "${_choices}" | grep -q "^${_ln}) "
    do
        printf 'Choose a device: '
        read -r _ln
    done
else
    _auto_choice="$(printf '%s\n' "${_choices}" | grep -i -F "${1}")"
    _match_count="$(printf '%s\n' "${_auto_choice}" | grep -c -v '^\s*$')"
    if [ "${_match_count}" -ne 1 ]
    then
        printf 'Found %s matches for "%s"\n' "${_match_count}" "${1}"
        exit 1
    else
        _ln="$(printf '%s\n' "${_auto_choice}" | cut -d')' -f1)"
    fi
fi

printf 'Selected: %s\n' "$(printf '%s\n' "${_choices}" | sed -n "${_ln}p" | sed 's/^[0-9]*) //')"

_aplay_row="$(printf '%s\n' "${_aplay}" | sed -n "${_ln}p")"

_card="$(printf '%s\n' "${_aplay_row}" | sed -n 's/.*card \([0-9][0-9]*\):.*/\1/p')"
_device="$(printf '%s\n' "${_aplay_row}" | sed -n 's/.*device \([0-9][0-9]*\):.*/\1/p')"

printf 'defaults.ctl.card %s\ndefaults.pcm.card %s\ndefaults.pcm.device %s\n' "${_card}" "${_card}" "${_device}" > "${_asoundrc_path}"
printf 'Device index: card %s, device %s\n' "${_card}" "${_device}"

_get_pvolume_controls() {
    amixer | awk '
        /^Simple mixer control/ {
            split($0, a, "'\''")
            name = a[2]
        }
        /Capabilities:/ {
            for (i = 2; i <= NF; i++)
                if ($i == "pvolume")
                    print name
        }'
}

# unmute and max all channels that support pvolume
for _channel in $(_get_pvolume_controls)
do
    printf 'Unmuting %s to 100%%\n' "${_channel}"
    amixer set "${_channel}" unmute > /dev/null 2>&1 || true
    amixer set "${_channel}" 100% > /dev/null 2>&1 || true
done

# unmute S/PDIF 0 if present
_iec="IEC958,0"
if amixer get "${_iec}" > /dev/null 2>&1
then
    printf "Unmuting %s\n" "${_iec}"
    amixer set "${_iec}" unmute > /dev/null
fi

# play embedded sound
sed -n '/^# ----- SOUND START -----$/,/^# ----- SOUND END -----$/p' "$(readlink -f "${0}")" | sed 's/^..//;1d;$d' | base64 -d | xz -d | mpg123 -q - > /dev/null 2>&1 &

# ----- SOUND START -----
# /Td6WFoAAATm1rRGBMD0X5pkIQEWAAAAAAAAACp2aYngMhkv7F0AJJECXqf2zfmmPIpvhEHGkPMl
# rTyt4wV/uoEzwn0pNqAMPh/8ADAo5QPts6GMLtNsBhp9h3SGHbKIZsQ89r7pNA06/onAgSFo/fqt
# vowbr9S9fHng/YA6UqObAI/NO3Z2muwVJxKvUlka061dl/F0XeFUw322ZqIeeCO+VpdbZEsRtyPF
# H8b7ttrpV1LnBCf+WPZitmQrSLho6DeHs1eeYwKqR7eA720hoUAs8/YUeEb3LlZbG0lsD/C5pFh2
# 7FuiT8DRZIl4i88U5u1THthPay+7EtjRw1yX+KwkExTKm6/I2Seqev9Ome/iOBQ3GD2Jbm1XWz9M
# QMiiY4XUTFVp9aE3dokXgtTnmU2av2qXIsb+80Tl+WJWAykXw/ZCxF31tCQQI3QlNCfz8CEbFV0h
# ZdqyYmeT9ihbCPZslWWgEXl1UU0cgAYBRCbfTiKEEKQGkeNWun7d6v+lvwswxwrDJtHMB8IoqFdh
# QcZrw/gOst+K5CAnpZ/BzbTnaMafE15N7SzVtpEuml0Fkx8WfW9wRcrOn1xriKUZcU3yovT5nm9k
# ex454H9Orp1y/q2UzDG3txzHrsQN5j60pKY+ULKIevHSRXuWwRHhTuizKrbGnEfNxzGi2Bf6FfT0
# OZj7D7DMaPCyc3T3/jBDo2+tSGjqOAK1cPYmEf73xnm5DNWwq+0+Udyj/UHVJrBHgNAg30W2475a
# dYkT0sCdV7bVpFgHdCZgy+Yl2q5DN4wKeV8srVROmXDgmJAkbrvtCi9G0dMtfmP2k6I1FGRZrk5q
# geKUnbrxCI1OQURSBrDnZb+fO2ElgF8RCtdpYyRTECRkT5T9YRnYqYCEdHfq4xWSgv4PrWi/1Uff
# 0LURUpPGxyNPNdH7SOS8wk11LTSNgYg76olmFEmakwnLcDRvjbXSyCr5grOpwrJENXAh5tWAYczi
# iMM3IsWCpNfJwmfGEx0KR/DueYvoM1m4D3oV5LOS9Gr9U9T5JBM63rFsdNQsy+252jVbL3SG8fxR
# XYFbHkSwpp3y2ZtK4y5znLWQg0lXJ5los4U3kULKj2uwxEIf5S1sIWgYVVrsWlu0wJFWctSaUnoy
# S7Je9DtcFPv0eFEbfy2TtyepWNSLFcXgGB+qcAUCnUHjvIszsPg+11tkI3r4BgbMfr/F83YQR+hg
# re9D7YFqIUy8wuQOePUEwCHDwkUyPajYGTO6FY5mtxyWye/ARlxNknihYx6Mw1ki24XOY5IsgOlK
# 8baqz9iVvm7gS71xprGO0vdZxcB1AZATN8r0I7DsTIZaawgsqCIkI7CASPRrJe+mnaoRrkHcuhuq
# 9s0ewcpTddJFnhbCTh1SaS571q6Oz0XI1CrtPBlHyM1nWIUmRsnd5oik4BYdT92Jaf0o6fjg78m7
# cJDLxgRIY6dI4l69WycywuAMahSNqYuKemKFr0Xm81Doa+vc8DdQjL7EB8M66vloM/smjNZiizD7
# 30yovwMFjcdWwUMhzamj8PUee916LjgAvuejn3FsminSDQDTmIZBiwt8f+e7ONJ73+68BOux8kwn
# LbSIxKFHpKK+LElVEwyDKOVV8HqMvWbKqMZPtGs/3Vok1E0JvH53M4094cz4zk2Jz5DGbn+4q2k2
# 7Y7HrKbb7jS2fXnCDrRe2I5Go0NU1m0IPl34S9rYQAgJALWXRS79x5P/sKa4jAquA/rNRXibIOWK
# oHUNiIyeVNs6ZZgatLNo5EfqPeXfJbFVzEzi51CDV/PKuZpwCd7aeO+GzQ2nbffpXtITfCX/Yedw
# 6v9z3zGvs2NzGDNmYIq6OB8K4anNanwOXGt7nOYJKfZ4S7x9gj25irGA0x+eqZ+OEwXeTUELugWm
# mduw2sXQa/K/qCuk7+y6DVMNtMeIOAUDSfeqwoU8RKaj3KARAcWJZhJbUD8m0EGXLokiQAQ/LSbg
# oc497s1vELyR/mXnz+Epxgsalc7ThjidpzLLH4TEmEXTxZPbuzxFzmGFS56omYsEsFIzb3AP0pVq
# G7LdiAe2tgcRAkDKZVqEv0uownBOUPvvuJIRaH/LrQwaLh5KMzFoi6cITgZcGYPIkxv0eJxU9I3u
# 58gxPw9968jkWGx4limH3CgvB6vsY4slMuCOiLKK+cR1T+4uyJFQiBjlYpJhH21xqPhTJQTkqJLn
# d7PaKCN4R11fM26hTj2piCn9TqExdR7aIBBdzbKXVHUt+Pu1Dvod1sGAt+pJ0XY/aPfGMlUtq/Ui
# XfgZOKQPeT6hVzLcvho9r7Xaz+W7U2N8BEAlFBpzDYK5KyQvju2kunl/mZFgszJuJ9ZM/+nkl1kq
# /JLwPCh/QhofST1vTc/Wle3IKf2s082NedGqJqa/1ut4HnfG8GKar7WqXAg/3s1t6ZQJv948l31r
# mxP6Hg7xerXyyrkCe+5BIupW0gVFbtPb0nk25aHucX0JJkhBNR5banRqbfhIpX0X5VwPWNtYaBrP
# QVzjyuEmoy4294de0xnyOf8eJ9wrNOqrQ7qpqpoveqtCDSc5Jz4OQKeN8HpAJnGXMeAK3ala2l07
# JbWBf/CVPHdjcCwCw7mNfQRuW7pj9RFiT6yOj2BPGQ107azm1bvjdc/THcQPTyRT3d2O0VdwuSZP
# Qe01URR2nlj9c31S5DL/NTWdoQ4mUCCDJLxrVJX1l9/IIuufg2OUh6SG6oY7nb01JBXvhn6R9Buu
# zBQBn6Uiv45JWsOkJPZ+0L9pzZoTJX1srUIBGcSRjQVvolJ08ND/+rEfOUP1XB80HLT2Oi8BKbYu
# OVXjcxi8LsDF+R2khUt9c1ApBT35xen4R31bY4sJw84gUXIWXgA6RSLBueNCq6AqkNK8ZFa7VbJ4
# V6kboqOAL1P+TeOTuhSj9etIq+pWzbYJEnRWJ8lQN/aKXzU4sKMQsK56fP7DguDP2tlQL2MycK0q
# q7k/nfsSv8PAquO1WhuKUog2dQ8GClrIyh/WcVmJ4Ey5XjiiaoH0kRwBgPCUeaHW12MNSSfvcn2j
# nKQx5l17zX+mIzUDv2AejaeFKyd4C5pwyNBzkvSFBGPnN0NrxSGlsB2KzaN8yGseEIPqE6Fvw9Jp
# eLJt6pZyLeA44JBQ/6qTxByLy8Qkp+9MkPnrY5HFeX+hTKIs7xsLIDL/BJLAaaKjP7878iO2115N
# vKerahJtEhe6ecR1MjravaQBAgPvbfnguqa6vbJFxMSdRRnNmC/fwGHOwDGdPFLaLjP4XJH/VECX
# fdX/UlVJW/HEeEVoJzUCfWXmMuG7KgrDd+gltjzxxS3z9g/hpl/uCQSPg2JzLdWvSdJZiZ2ow8FS
# pDIv7lz0S+dIzNupl6nT/NuFXtoSx6VvlEMFOOYVxqoTtumlD98iF6Dy38M1kArosh8pzS98iCRK
# gwNJ4uQzXossa72aCOiY0504HfXDoLX7tmTdCk6iq7hNpacUk4Sif6j6/7aU7KtK+K3TTkKwKEFH
# VSkJYSByO9pv4TkZiKX3dCNJ1W79SzfufRGrXhIjhoYigAmE499Tjayc+M/ByVpFsXo9isfKKnm6
# 3yU8C2hDfd9pss8c3jimZFOEMox4DQM0zKmGSWE/2LkRoHj0sR346VtHthyw8Pi4f34Xn66U43r4
# IaPCakrRk+XsWcasUXLZdjs27nxSdB9r3vT5EFqGmPDxleesi/40SNYYoe/PksuXDgF2zzvYiyKR
# GYtGoUpqUJLrwLf/QlR8UPh/ESKcW3M7yCjxFORl2PFD3YcUwt7g9wC6UfT/ke+nPS4IqoxUPhsp
# 7ff4Ztxqer+pCxLHUdW5+TPcCOIDjDK9n+ZThEy0C28I/pqWUfj63R8tYb3WxadaUgWVGAmg9XkU
# TPh7ZlzOKR6uyx/JzQA241Smz2bSHBYcvIQiZwatbEIj96iVvcdYL9OoKd4VDEK3Bzb215oX2rLv
# uSvA5SNcuDNJlJGo37+DOuxLb9U3GgJ8P3FwioNSXfYwgcdWCFt9HVfmAZvS5PMes/3+mM4nXveo
# A7mxJyUqLMGRCLgC9j2XAgpYQuCijsTHzo4thnuIHMWXwV/1HtltliE9Fz4FwqGCvDaRYi/R9VNW
# iRfrSzMatQ8pAw1in9FfCuAVOOyH7lfk9ki8SmNCYJmzxt5Zm4G3wJtFkce1/PKN8vm++gD9TKXi
# lanS4vgIJisl6AfVFOWG3MWUjp9VayjzU6Zuby97mUFKCP8ng5mcjGkghci/JQ4S4rGdG2y0M2ce
# H/W9dfcHsKvZzMhzI49QJTy5cwc/PsFrbdIKKmijDn6HC+ZufSH7fdl+CoFYCKi3nQQP99CbgB40
# 9DcWQnkcbFm8QMM4FfXpNXcc1zBvlAUPmnfRXas2OoLjvzbfz/nawqMOHnyIxmCMwBpw4CgVaekB
# B01HooAANKnM4uY1UwUGdWkIQcuWXK1FXyYPRebi9FACT8TR7I+ZztWrMyseWFsQkj5OCaU5pn40
# a9ROmGBfe1kSO1KVTaMngOiT7R7YZkC+c7A4YRyZxaW59+E4E9od8LI0lY2bDLIwdt47GnGU0ozQ
# uBK1/oBBcjZqHbgC1hPkOAnyaGOVrULRLMlikiEKnPtFQ61FzpIJUHj4Jc4p+IJ8t6g/4SfN08Py
# cWLjwqpREUsNkqu38SbQr7gdEl/wl6QqATm92JP0KimJjeoGZ2l11WSpH5AlPxDNerSiZb9Kltwd
# /9PcJk0ir45fornWkqgd1S+/RMb8LWB0NfCa+axwmc1yiGv6GF6k31pJuNYJ+4dsfbkZpfdSaQ3R
# Cm4LV+NpIt9cgFEzwNOZf05oH4h34wJiJp4KTTAN5O2Pj/mC8S8DiV9GbOux6brXmFmxZekYjwQa
# MAduKa2dKK9Sn1Y+4WRBDgxfwiL4TrB5WsVAo9XZbVgo4FEiY5QBMr10+3j+MuiEh8Urdh2EZOg+
# +Ngn4FpiEgTTkcLzi68q952i8g4elaGxDVbKm/OEMnkSl64NQ2UZvVUphdD1AoZsgWDZf5Nc2LO4
# nyRIOGh4TtSpgZzuxNMsLDXftnrIkI7guJTQ0IhsNefC7ivX5VY6aPLrC8Yl76lvY6xCRM/DUi2z
# ogpyziyQGjgMwp8QSOJqVrRtqbQxvu59de0xSmr2aZRSHDg58qmHWdVYLXwF0mnX5KoJtYMEeaiL
# 58ON728MzqCMO9wnheBfQ9EZQV72ACsHNngmeFSaoUJxDW7aLWtKCL6IPccunGp4xYqtquwtLAW+
# jfeVAymzEQv8MZkDrrh6elbIedArbk+UQwqfuXRfu2YJFL88RLcxdCY02MiqVA6LBGRwXhDHtcQV
# vhLLHJY6IOXJrK8ngBjLRKdexNnurLb7eqHHkST2HvDZwO9z7rBgaHg6J4KXxMtEl2inGUNT0xew
# dHkcMiUgK4BTlcr0Hu2xuKcaAG3F10Fawo5ULKU9DuIlMAuIAjfSVyXExYV+CJTQHx5gAYx5fLOi
# UYYRV8WqaurukELgM4vR+b2cO0wsRz1IkMwR+Z2uy1WOCzBG1wT+FTpr5LKLeZ2yNtemJBRfo2ql
# tErUlGf1DNWn2y/iQ+m2THNiky0Gr4/9D72oIvtolSaHp4oblKSnP2mmVB2V3BpPyyWdODw2KRV+
# tutJS9dAV1KTASEjGQckrA1QiRb/x2ulZ1eAJdQVgrNHTnblQAtA95BEewXdHAEbRbdxApHNWi4r
# 40ZXexiHUP1k7pbMejFmERxUdOiYGdvifmIBgqQZTvBP0FqqZip+EG6c6iFWSyS+iskOKWgdgSBd
# LZ2XsZW9kZ4EkjrGAmL70dFagENfPUg6AM19ayBuVSpWH6Yk2xQADl9yvsUcHxlCapiUBEtj+mhq
# 82PFHIKUSSmGTLTiaHhQq1iutktWikHpObXAqVRjlGUE3ntaVFIMpODb2nxHpO/rYDYpjDOiUB+q
# kZdpCO4SsJAzVzw4RgtOtx1VLbXLNNRRM50R3/hRVJ/ygdYlu5UZlKie6u54WZK8shT2QPdhHDh7
# xPhedxD3vWsRWHJD/w8bo7xJaYQtBGEJw9eaE1IA7UdGmPONo0ZJKmU/SSKA/2BHgMivCt1YP/SC
# GgCUrOC8iMuBksTH3k29Py4yo0bO0mS8BkPYkY2goIBcIfXJoRzQuLvF4lUg/3PvwZuWU7G7i15B
# XCfUHbamp06iX1aQThRhNcjwPeNdsW1CF1Y7OhGXn0zGfe0OOnOxStldN0EKWV3qD73nDqfKlLtY
# VvVME9+dPOQerCDbWtSuRTKcy8BrPtZWHaAvJERtOC30TkCEHQoQLT8TefK9+mnzcaKMd4v/aB0b
# QJaroUUknVKtmhjBeBuqiUuOkqjhjCzIWiKt3JwLUt2m/pD17T6TtW6APjgyg80DhLULdg5b+NNf
# NUN344LCYSU2lasmCH30f/QpXsQvL8mn5cVwDOR7tThw2pMfZjXuXpVJrRnPlFWUmBsbQipOEmtA
# sA9yMt3thJhzKaosJnU4wbBcP4wOWedty5bm1X7YaomdwlwEtZRv06GmVafSmglRtWnEz67Hhusa
# Zxrv0jm+IPntOcx6dKYvaiQgsJe/JvWH9MXF0IvT1a4UbMqfhacrl5Tx3Mf1Y3g3IAqNnU4rcn9E
# yBSQDFX6LjJ0J28DP11nvJN+3WbdxpWEF7x8c5nWviu3lRa+WmIKTqlRZmnfcHm4IOvul1qvXEk4
# jPdhrbTT10KxO/TCKEZl2u8NwxkDqdamJG4HoZMMrgPdbGRuWfdl1Vzk8jFeQDjA9byXmLcZY8yo
# I8ra5mtkHeJ5akp0Z7TLIZ+Di1+mOmYRlV6m7qaOjD8R0zz1rub9GBEzwXv46BQ12lkBl2zzCOYS
# myuGm+n2vMiA9n/rrP6kS3nBMYovbjUqAkIpEK3F0SxQOfx5rdVVSof1ymSVIfG8H5zjCPw+eSJH
# snh+/I4ClAAXtwqzy35/OhDyoyaAFfs69HQ8MBNTdv8kJbirjjXEEYEuCokkWGYvTaAiEla/whDv
# ryszVpr8ehNt4SQ+ADgQuwKI3QIiuEefFztJ1wqftjpB9jmzSdpqZrz2vmWdbgioYg1bfkWm4aim
# hZLNYiii7KG0PCozfi6rQCVIiYH3wg6gKamdtN/MMvGzEd8J4I4uZBn1hPtDcliOzLClcurjNYzp
# TySmxb7ZncqD1rwoLrcsxzLzU++x/Q0fxT70/KfqwjBrldbFttE1UkPnP5Gi0eBRZ4ZxDzrXSojC
# e7lQVMD9p5P8TKT3OvYPGNNhSUP1BqL54luFtALKJIZHzrqPsmYOQA2vCr2pfhdsBrxxfWea3CG1
# RCyvBuFVfZvPN1IQybMCtREKmFYgsL5RTTYvNYwvwWGjwSFPw30KRJjZzhMXU2NupCcuHMxiaw6O
# 8o5pcalBD0Mfj4SCAzvUh6Y/kTcUA9FslVP1AaFkKx31qovclHvEUnQCP+YXAzIur2snrNHaRjyG
# zP35CFFo2NMpUhV5wJgmzAcn+TkWovVDuLHGmOgpq5c5QJb0dkRwi4LvTeuxqahcfsZ9AqRnAVga
# fK4qnzc/0k5Kx70U1JGsL9Zqsq/kMGuVBvVlWN+krW2mduph/6zpDmu/WEh21l2uzAzUrVHst/Hw
# 67N4t6Rtj+ZGBmoI0G1OJfeGUEwydeVTwU0SWRHF9w/S7s0koHtSYT5L+6sRyp1pds2NrtP0q/PB
# uilmSdp+faFju0hNEJi2slDpi8o0kxoAFjvlum7buGQml6CwEL3iPPARKmMxn/vfNr+7GeixC7Ta
# 323ECB11/JUXA5Plf/8k9fchljcAwxSKCy0CYpCxsn6dpLms1IFnyLvbJ0OzP0mVA3wPDODY4WJT
# crY9AtB1cceGA8NI564rgEHNy0arp92Dhpoi6uejWWRyJbA3E6yCdOqVGChMsmrBywaKVKirEJ5b
# QXrE5y3wW1pAdwiMJH0VTgZ32/hNeHaOSE19R/EJNFiE/UDvWnpFri67fx5j80ZhTWZfXXo6BvYJ
# oKOCGALqpJw9IMYAnbOGB0yBTqoFvwqzs8UovikySiV5VsUbysmegkjFcVJvkFjq//yfR4OhxSW0
# GxLSk0dTeo+23wrWmKSbkyLj3Iw8/3BvpnML5mKbrjmNR/MFObsULzp7RhSc1cBQEnCuCD9dXX2R
# i7recu8sTUaxf1EJuBk8b9Pig8WINnzIZO59gakdK/mtUaDDhkODLoPAzL75982JJjCBJvgjwzAo
# QND98AxUgkli3tW52h878H0j8KyIjInggzdARx7DmEouwGHTY1Nfx/iIH1vuo8XUyOyVHzapUSm7
# pbXg0EsWo2DAHbqRAfjkLiIqlIWGF3TTMnPBe0hnNm/Ry1bMwFRTeHDnbZnw/7ebumM12QJ+TY5k
# qgYMC4h+mG9kTHSmzNG3fS6YOZcitVJivMWY7H9QI4A7rkhODlFUj3pJ+Y1xR5vsM7P0UfsFYWNL
# Z3rFLhAqq84UD04IYadd8ADz6mA0b4K/6FjepmDklVfA4v/JAHqOsXq/jn0AY+plbdbVrY3oy7t0
# E6GuveDgla6NAwJcFZFQBlq5/6ElIDQGghylYj/xDvNPgIZDQ7KhcNmhvNWVohkz3Q5+JlKeAocT
# Qr71iSKztMfpZeojewksvqLh6mmj4baRF0JV9mlGfXePawwX3O7/z0ioFLh/QKWqdzaPYjYBx8Lt
# 1KEfynqjZQ2msT8sfpdd/0w4mULLNPoIPXsI/2nbsmEphqYwwBRuosZ/kCGU41w1iuM9ioskqZOj
# FhItfP19a/0PHjk15s1Yo7F1WcdQzdZkLK6xAshznF4Optfbr9Bex8w3t/99vgOtzvWLGHkiHGmt
# Boo/py08jB/Ikt/ncdoffSlMMj7wumBatmcmxwt8q5cEy1IskX6JcImw2s+BadvefSbadS91iZgw
# R00HQXgCycEEFGBd3TYiktAFxc5OCJAyOBlODrN3KyzQBSSRe+CRUhCuPdobWXEp5pvtT7Q+AeQB
# EnZPxjtRPIwoDAUr3Pg7Z+EHW+/JuYB1rcwRHtxs09LgA7hnESik0L7OMCMDhlIxmD6K9We/qb6E
# pjljxpnvxKrBOkBlhX0jB2pEujg4IzOWnrgEkq9MsWqKC0kQIWMNqhWudycd0qNO77Rf8+AdFdC/
# LYVPo7koADs0LHcpQ83i6abDY+RXlZN0Rc7N8cTtmqnYnv1DDAPxxs9vAB/er+iJ8XI5OGlaHgrS
# 2j+hyxlh13dzu5+ebREw9dDK0u6bgBT5TaEmwyicGgUc4hnAaHS9qN2x4MsLp00DHOS21ZoHQ5aj
# rkESXXFRqE0RAqiAw0YAe9Mg1SQS0LLViEdaAeSegAQT3CJDlQbhh/+t+y852L75Fg/DA2bx6APF
# wekZfyv3OzFAXbQQurizQ8lXeNXlqIwEMJsMTVwoQd8ebxDJTWqvScLxbVZ1LUByVj6r7D6Du1Qk
# 1hk/jmIk3Y0MGYp4/HXR7GaGr6t4aWGaqGdo7yV/FKv9Jt6v8ejE/Uc2lLXnJnoqPw1TeCfKSnYE
# vb8SYUDZJmCVzy7sQwj+fYElTFNehrifUD+S2/ApKBPVrRWaQYRtYl76HrrCa2Lb2wHRxPrehDFL
# Myoi7p8rVaC7ILjGO70Pix4LsWx9//tHFhC9OI+BnGj+LNHFe2Q458XZND5pBkrEmoLrb9qgN6eC
# E8pOaIAI5qz2FN/PrUPG6/FO4qJUWoxWQp9yhHycFtKH8BBTLU2zggjJakMnRR428soXQiKDRbl/
# Lpo3Zeq1JIBoTg4QH83UIZnHFysqZoMzOuyGkwkYC7a4oq6nbnP7BT+L6AXQ0bDZYgQi0xD0m1JE
# 61OGMQrFOH6DiWRq07+pJZvb1vzweKf3I1nguA2+VUNljCei1PnelCe6BhQBES2hRCJbkkjooVqT
# /irZPkiSSjYtPnKaqOPUizaaUmezZwyC17GrXz5EFksslEaazniidWua/DzT/nhb5TGTolC21bOc
# 8wrjrdlVTS23V+cEHEkDk9mccHEGXVLW4ye/M0+2VjCxAw39u4uIU/iAWN1zA228vrdNsTSwa6TG
# LK5KLuhqKxsKGsy3agBxW68UUHAuXFGVK82dG+7M4Fmr58y3NOOsXpnJ5l9UoTh3ZJUyXxPrsDK4
# K9jZ6Q1PFZQO8I+ie6xIX5Py+oseyHYfejCN5tu0KN3gp0APcgK9twLbQYY4ZX1yivyKcLfgG/VF
# qoXY5wsT4FRfqdSZ8QLJw3MY3LZHvTWXxmBpUZU8IixRxnT2cM0VwLig/GOXT2DJoY4oLuNW/ugl
# OL5hxfuTWteRgr2sfTChT2yirO2mxkoonPvs4yNyLAUf1eVfNIZC67uQiIEwwcfhdMDD7bJgc4ur
# JpbkE/7AwFgdqspBxkwR+XwpARX6tdLMpXlQXRsNQc7viE1q6dSwYYkd/4I+xIQ1TbK4+aKAx3hc
# O8+jpnFxV+GqZMIsRPOMQcJ1/adEKlhLkaJI/iFr/EVzeubMTIJ7sZ/LHhJ3VEh3aahbC9cETc/y
# HXN1aD4qBoYVoQZ5XuV+ROx06yXJ5C+IaQS7H9wa7Z/uQV8pYtQ/le26es9WsSlJNu6xnW4Gc1vH
# xzBRJ1mDLLBRK/goQSOw548Dy3iKzeJNgHV3TAWtnpQ6Q3QFnF0MUWrHLVVhv3txODZbicapse48
# O5Hpv5gnKpulIjwSNgsvCICTMXKOCUWUgC3oMwXb2Uhao81zZv5NrMMOKSeLAY4aJlFvteW+fHxy
# yGGa1QbucX22geCRD4qJfMBLNHSaBDrl/QYpVRCVTTQdSUNfYoG6iynfJIsctazfjkgj2ZtWb9A9
# 4HH79Nq4pXT8Zii492i0XQALkpCs2KGoaI1yugoejvXCMmumEV3jJfp5Kja2nMZeQ1THF4trdi8P
# puFVE0/zlXWJnt8aA+tGxSHO8GmiT2oGmV74+bMn7tlz58ze9QPEqkDy0X7qEZ+RilVsXSHlPb54
# lUqZkR1boPla+tVdgEGj9SJkKky9IwW+voKpGpMxdDTWgJwsopcwExvBqBRRWql8TaSAn44FSCsY
# rWKUZ3oPzbLTVhtWdsPBc2dPZiGwr73E+3b3Ko3tfyvF8tNPPMuidK27qebz/lV2JjsaV0rK4/t9
# +O+iLksxhTdSP0aH8ZzGbRY/A56vMDyTGkwTWsGa8ravL7LlkDtBh+ujSsyHTAK0b8V5boaYtIZF
# QvU2+K/quTZGey6Zk5E3+4tso9c6an6XrRt8mq2KuxCIy6zhRh9I6WqTFyQoQoEErlcl0s2jyTZ1
# CqLUaC68euo4yW8OFq8KKQaGA9qAMgL4PuYirMAizrLdo9GE7UcWXkvGdQWW0ZnY5GjZZrx8HPD9
# 2NuqjsVMz0Bx0byvlxEpvGi4Fy1xVwJivVNFr3qbxVwmr6yFb6cgw1rPRytBzZ9v5A6VBNrfFLmn
# XrPIzRyjWuvlZfC0iqHL1ekc/Cth0qb4XbzjMQWZs/4iHN3ngpy9v/1XJb5v05U2bdR3dnVmefCk
# 0eKYxpqbmdEhzLPdYz9rLJk4Y+u3SDITvxnok5KLhW2qM2/ZoeakxCGssAIr2Y53CfwvKFGr5fav
# Cxsi5AoAnz8Yrcw8/H2T+VGmR4lRn5wXf31S4GeAivgC79XSAc8gDewEfczDdqsdWNC2kI6zxfJ7
# p+C6wBH0ykHyaIvZFOLIHzLNd2ZjOAGn3QTUzhQTu4ht5oZ8RaS9do6E1TGJCW0gKgAcMfDnciBk
# M90rTlIPxS3ZrPvVJljnVpAjQgpZrjjIfU8PheB3Sopv1hgonyL0DTypt0F6Ud9mS8rW4prJShkO
# OtwpszlmPj1JXBUzi+KwG7eNddvxfCTSEb5SwjQM8oe7gfFDrtpfP9iDiOFgRn5rpiUn7U/RZpib
# bh+/SW6NdSmSv2YZzYkIHO/xP8r1az/XygIvBXMaH1YuYEgatIuEMHaIUJyHNcWGX83/u9mRfIlJ
# Czmr5nzp5bIO5pFWSVyQCHWLNx0DeCsfvc6pie2fdlFV1XB2v3PaquoIjFqbAEpU8mg76zCmS4Hl
# KJidUgJDhaVkwq7/I9ILeru8LA9rEJqMZxbE1+jzgN6LcPbzELaEQwTTo7r0ppcUF8YjiEc8NYRz
# zINhEO1DCHBS5mwit2tX6hmsE3yD98D6t9TK0RlgKGXumP9hUm1CgXD4ztD4w9fNFWqfL89Y2MHU
# Y5V0/Whz69ZxItmWQpZ8Cc+PCEifxHyUCxI3veSBTaX8oP6uo+IFSfcdnh39BxpjYg0fBjdDdKrV
# iHf7d9/mDI3QEE3/l44Hq5wSuCDFlEev4n73vHdakXsMYJEzLzjnmszAJ7Xi/BSJBAMQ3icMjHq2
# TbhT4gjNNZGA/Oq8sPZLluDiT5qo5cDmgIiigLVF8Gqm2Nfc5IbpOOyYdLU9HrLf3yCGhA1cZ+Er
# fDns55XTILLJdk7gaTLIXza2C9u2jfihdgutze4zPNBrMwWQ5cP+K+N/RnuSFzw1F7KJwYGNveP2
# tEUeJxMafpkDnX4YG1hiZZTH8LkvNV3Bfp9/OKCfhFwdPqEvJUH8EJdh4IV2ASOJmR6Q9+VZL1ip
# V/PSi9F/BBWXd4qM750vcVmXmoOG3UXMGbFn4Qr3sxxlTjRfoSj811WdJJUD9+/HPAHqDblAfgPp
# 6mibltqPnMp92uCrG+0YkDOiGnVy7Kert1aZ1h0MCfzaPep2ccBErIPoBKqRQSstnDWi3OOlnIxC
# +SiWv+RlwjhIl0yewKXIpssEB9sfKjFww7P1/zhDM+B2Mekw16h/gjs+kE9m3/7xVnjiJXFFIFff
# QSalkVw/ddfyr5QzrNTuBw4R8yfhIMJQ2iZWO90EQ2SbPx/6CBO7R9hDzE1kvolWgpf43RNtq4FC
# Wk6n+b+tSy9JYf3zyKjEpoC5x/PGwBcp1jAAjxi1F9ofUUQdU1xSSMzpRBZENnarS38gAv/mG5NO
# f125moaI1KdIEDEmWz50S+IepHbnui9vqdr5mJ5iXfGr6QmegXwrGsbKeJlIx6ejS6aOdHQmFBgQ
# i5YQwkrkkcHDMcf5E++qckUQgZeNttI08MP7YRVXyCjj9d+vwxFWRKYcarHQC9TrEqPFZ+aBjVAS
# 2xKgEc4+QxfPDhk1N7D/C32l1BJmsjoBYIso0JYskSPHyihyJ7ZM24jsg6VDnLUDIKqpZx4DwfQR
# VgnlHRpN+TxLhEbWLpzpsgTJ2E3ZadAWC/tqd82T9XrEEqdnb7PJ6/mgmzrW7Lct/xfKb62QclzK
# 8OmTRbcm7ne/J83/XsPI2HQ/Xm/tGFJ9FHTq+ZOT4Q3yxSkDzoxbNx/DDiLNwZiy7ZU1CKwe2YPy
# +sY3Gpg+xDK7/GpITxK+XVjeZwAkZp+B1wNonLQoVLsB016OkBRyhRY3GjgJii0VoCxDyg6xPFQo
# ap+l/ANHelXiq5kZpVKJHfH7NA+996DSOTZNSOINl3lJG8uB9HmuUMo5fgyt7xgw6O8DnQvHFtfl
# iCl09/nHlTkRslKTfMR7yoRveI0umczhRzA6l4GAmDZoJzFlKAa/MAvzaC7qbFZ396IXS6+sMLSc
# MqKauUj9FpBA6Oc5zBn4KkXxkmlMJts5w3Z/LVqjgdhe0BApxoUZ1uezjNhIMJpZ0bov5C87K+a4
# vYLciwZ7AYzjBbq9YYPvMa+dU1HSytKgrCFCjxrHIRtxwIierCff6o1xHtgMH+gtEtjl2wmSQnHL
# SCwsu0yA942nmICS2f7gk5v1UVUbyl+0ug4COvnvlsSWH/jpKg/5eOF4219wg+IFZAnq3Gbak/e0
# btlEI908YatduaHR1X/+IsXom58ymA5pZMA9khScuxjQPCa7Pvj+y/OXLmdP071p5G+rGWPNk76C
# sbk57ZHKE8cYGGx8EKBHzWQPOr/D8SQ2nOJGm7cNQUGhUwSlEPM5r431hvS7NaFlKwEvPA14BmW2
# JRYecg4cSSO6+7Eia3JAfuVITsM8XnG/Zu2ASaCujRe2EoWeS408n+jkIce26zfCbu2dz+Sp3U2+
# ifDmoN/oYFZzyaPbSqjyokCH0Cutji9U8drkZClc8jteqX1FX6iWpuXbOaOLfWqpwgvDpO1cZnJZ
# +/eUk7dLr4Lz9YwSxc1agNfHiKeUgY1b/89jc8g1KOmUq055kjSOKe9z1OrSoYyf0ZTmWu8e6I5R
# 07OsuI9UHU8I940KhxFVEflpfByazqbHa97THoyDlNFySiMVbaDViGZU3OAri4shf1ys2Ofu//Jn
# 1vXbkbdCF9CbXhAGt/v143nfZCuC724e8Ki3LC0CE/Nh5t4sEOe1no/QVFPsaxs504TEcQ1Do7Ts
# lu9H1L8zMgK3UPYH+mJIc23LVqO6jgG7ubugIbI1yy8DKmCXxHP8eE2N3TUyi0E2tnC61Amy8rFm
# PedZf0maNex6QIp+kV7Al8I2VigxhcEEJ7WvmGuvBS5ynRKmR/+D94eBS8CqaEePJU5fgUwdt0MF
# 4laiIUdtnpriTHE5HuudUfBUWpDzPk7c83NWu6e04ISJO0KStxmKcYv26ibnLkbAqf2kpYrwjTbJ
# dGB7myMlg+giJ1itFb264/vKYFeSCmL7FmL4zLaYcx6b92/yYHVnwxuXqZCTDYx/lRjMT6YM//cP
# DSclUpS++YY0PARBGJ4GiITSyplXYOpuYKdm8azwkOAi4tM9EadIQTAUuq06di7YihYuclCoVse3
# kz7oq8lZ3JbYXCLnTaXSGXZvuRNxX8aKbHC+G2l4f6+NTo2dxC1BTU/gHoBJOBI6D6BTX29MuhKi
# PEE/Cg7KMcjcu9Z6w5wHolIl0BBlAtVvYQTVKfYDhBSDgmFJDKtmuSBa6uTaFUZYG5sRcg1VEYyY
# j9JA7GPtXU5xZp0a0W8m+93AsNxhqF8Lf+twD79DObwbYeXfR0EK67j5KsNOgiyjkbEoR19a/DW1
# B3cr2idXJYV1fNeTia7pz6u3wMtUh92Aq6uinH0PIyvxUsK/1CKfKb3vIuwWgwolQ4rDd2ZprtfB
# /oWgeUzTaiFnbtJpLNiem+Q/s8v9bjcw1f4VLGK7FUdtDIm4k3uTZfNFzVDXzGj7qIilJZBMEcpI
# FVSjog+4M5ldWKmo000roXlOrE5J4Vv/QiFLnXfbDgt+qxmgyyK+9i6OWULHkmJTfVmkNm1BWY38
# oWoH5POpWn4v6/OFFh+UgkigDgkjBX70STEqIRhqe3aGyd1VOKFMpQUgWSdv0gSDhe018ihKAnm5
# AMqiuqLy5CFToJLVynDxvV1dqizhbmgZQJ008dQYa1Hr9HzykffNOM1469wjwrZXTcZ8Eh1VoOJn
# WR6cSsd6ApztgFL6fRl5CLk+YYAi4ax4ICSgGE0QvzvI7YCaBdedec3WkmkzUGRrnxFVP/yPRyRI
# iC36tJSYUKPkpf3/c1D+oAxApU9ck8rIHmqUMa3piI6L21KXMiqnvNE8GWc/gEEHPoq4UlmynNcl
# P52wqKMQN9qm7KEjdbfmhqainSk6NSk+CGgHkyJT5ziXAVpYyHLLW/NUQyz1FeFrEHeBw0zOlJ32
# I6S/r4FG2UOSfDcrPvymw5/slXu0csCM5AIlhqaRlmpYjqbgPUTFHtgY9C1M7vduEEK5mj+pzzws
# p+tPfPNId9beA1ulDY4W9j/3HTtViPepLuGemaatTj2skjh99FaPxDsLOe1fVmEAlc2r4C+vl8Jj
# YKiALH4rVxlsAwWTW2ZckWGoXA8vUCJiIKyTvqi2P72b5y+8oL4h6tItEPa5UzH49lJQWDVhkaqM
# Fz6keYp7QtG2vaK/NovLrUGKR9JxgK1A9tcffeZ0XDZUPut01byEFld6p3jGUF5Y9aNSY+TBZAjT
# b8jAFbdbf2ilBBFSrNxYEC9Pa0jV2aLJUFlXRfAnhJOYMpqkIDTlMkDvxmFVtigTPFQDufn4Wo92
# gugYBlGAX1pQZeU5HhAw9dZ30lQPAV+Z3/Hoz3YW2w0a/IkbBP3oY686XsvyjsIyzwuDHj7qLMCi
# gl/X5U1vv7CSzqF3dMVdqST9xUVOp4FOVAp8OnGh5O+1QfANMj+NvLKndS9UaPBGlqvCkW8PyHEM
# njHQXc5YIInsyfIsZc9GyFR9Ud57SLK+wPEpbMYunrBlUs2NitVySEcyUE4SsQMYeRw4V3cpCZaC
# u8nGXl3UTx2hkb4rr24RQQN5BqIBBBvTEwQOHXucN2K8tuhuaVfz5+fc0elxBo4Y4rp8RlAsHOyW
# CesCwn5gT4yq6O8dALRJHj0FUG0SaxlzK24RVU4w3YpNF9rcbCJXog71KGUHnozPA3ittKU1Odtn
# +WFAWa7HHKvM5DUOe2CShTJerS/XDU7Vq1PXXxgsHYToJxGVwk60pnv9NUxB/AWuSWUhn3ZwKVIX
# B4c5qgWuuG/MxiVzVOGH0JHcmQzrGVk2U0i+cQ5SHy0JH/e87Ai/TJzNL99b6LRDBGkamACn0Sry
# Y0EoOgABkGCaZAAA79ci2rHEZ/sCAAAAAARZWg==
# ----- SOUND END -----
