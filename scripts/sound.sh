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
sed -n '/^# ----- SOUND START -----$/,/^# ----- SOUND END -----$/p' "$(readlink -f "${0}")" | sed 's/^..//;1d;$d' | base64 -d | gunzip | mpg123 -q - > /dev/null 2>&1 &

# ----- SOUND START -----
# H4sICE4ExmgAA25vdGlmeS5tcDMAtXt1VFTR2+7QQ3d3CkiHNEOnpCgg0kgqnQoMLSFS0iidotgo
# KkMpnQKKlCIiDCBdA3P2neF31713rfvP9/3x7bVghnNmzX73s5/3fZ/nHI6xnjwxDD+MbHQtLHGv
# XDAYkayKijKfmY97cEBIgGcon25AcGBAsGuoT4A/zObKFX3cp2hwn7rsGu55SVZKSUpWRgb2fwfY
# C4T9f8POx98L90KL+7kEg8n2weCMjOzsPDzCwuLi0goKamo6OkZGZmbW1rY3bri6enn5+QUGhobe
# QSKTktLSsrPz80seP66ubmx89uzly7dvP3Z09PT09Q0NjY1NT/9YWFhaWllBozc3d3YOjo8xmLMz
# CAIA4OfFxeiOi1FW5f8NRoiw8z9vZPvU58jv/u+osz1gsHcEPLAK/J9EZwRauIN/iEi4zO4VJkYG
# wrw8I2ftpCI80UHuX2G6pub0lyhbi13uf6WwSqSAPSNcWmAuJrr/8zv78934FxPwytTLZF10VHKE
# WpRCxxLKHvqhTFR6piIiq3Qyt1zMDZLoIjIkbvx0034Q5ehfSSFTSq6tTSms81F2IuZ3ET9fLbxY
# XR8+9pt4Wa4KYWRE1GGQK0QulB1KzZNkvUpZFsshkuJxIzFb0NWDefjiddXsMe3JPr7XaUvajMl7
# Oi+9q6IE4nOqCl712g3/SIDTdRYp3EY0Fixvk9OofxDYcpaXuteuApNg8y6pctQr0ycBW5hs6XqH
# UEwp2Puph+ZNoFTLGraE6RCz3OMtrYTph7GVqIijLEY+Ca1zbTORdkWyd4eZZMNYa5ILSkQstvsr
# CxcV5W5OhyT9/GVxa1P0MzmXNVEPg7CL0COXYTtjoY4KvopsChaxCp+dhAe9z1WS4o0727mVyETY
# 6VXjyLVWErWI+2+M6fycI9iSJRa8378jlnY5oiqnIplS550unG6lRrZrUi/t6IFLUsJDAffUELLt
# N3FrSVVcH9LpVJKiCPh7h9Lv9SfwRXdMSMlrh+Qk6hPJkaosGx2/p9y8/rDVqlr0nXdJtoKXsgUD
# 2QO6vS/9VY6SfIHPvPtepIX2tD014lMl6UirK/16p5T9py9Tzkup/Ri9E7ZLk4PXp45Ov5pNl4Tx
# qfwJe1S3p7immGk+qW9EGNfgjEUWZ0dOGdHpwRwM7n4ktXp8re6h32mBaaZp4OO6zKvLjUuSMtZ9
# UVN8HjYkGaarNbk2dwjVXTK+9CNWwWCHLqxKlDz7QJzx11DRL9EHvziEL997eX0hW4ZkhwzMoiek
# ZsEB1haAp/Q8hh64kAwGfXNiYmt60wF+YAHATOrzGP6BPSe+xf9OS75fckPuTci1umoDDo6BmwV/
# Jp5gCkUssy0dlFdNBn9+fszvKloicmTUz1w1re+py8FdtesMTmiIeciStBlCP+qnVe2wCPTsvJow
# PjLJbmGUBE8bJVnAXoXeLG0/QCA3X8MEOaFw59kimH7wcadsDFNM8WSeo69VbDICnFIKpQlupKvC
# QfPcm/PoNpAANB8/7e7Jd2k6JoXT8Cf/gUkxyklrtUUUdgzf1SresvO6rjU4RBIrNyZ8En/s0hrx
# 0tf89Yifa5PxSx/UUyXQzF/xR//jXMhoVtVxcs8/W7G8P3IYp+N0enkLLFS6zldCjta1buTr44+Z
# LgVgaaP5rVV84DjtE+xNi/MIUAA4UFup8B6wKaSSwxR0yb4QsHGlt9UWzGN3j7MFvV4UbHdD3Q4y
# m9qKS2dXsPWLGHWtYGLq8HF1cZ8xLCmoILHjyRU1y1sOitYKajeiDyaVJ7ZM519k7FRYBHVQ2j+f
# 6wEbJdnXvzpUTLICcD/qdhjflQv9STP3M+fvUOHqiN4+HSmlirRu7iUBJpYEaKZmea+6ROnTKhK/
# eWQArKvqfXZeCSuGhbnGGCLewQIvO9u+aGwBDY43FWLKZyOagudk5nRm9a4G92Ov/Xu1+NwlUMi/
# +d/LmFssOwWrrzAzyOMGEst57hqrDuHPu2uRH/2F4odlhD+hKZZyWrCOPHWlo5SSemrg062nAKCF
# knx7uera88rPknzO8VnFRWGS2VXa5EjAROBKb85GAlujGZMfMNS997uk2WOXPXztbr69DSE5vxpM
# 4UvL8nCuje+DID9DXx96bXdf55oD6K0csYdcl6ZRX7AFW2GKQo6b5bMmVfnKRN2FcGPsG/CiBcce
# j1k6dmCIvN1UxNfMcgeae3Bccuvfvu4DxVaeWQC0VYgjVyeNFVVYoepePC7gAAHAnCUBP9nvgVBi
# WJzyazrJa5tna2rDvpomnJ3y+aeP7Q2djoU8oxUk1K6J6T0/QevmXyP8gVyxfZpmda0Fg5p2IhiE
# PdQaFCDKpu8RJKp1F4jO5HWjp3h5cW2CKlAhoQXtk7ipP/ElOt33yfqiU674Jdyk9yNbnz6RD/2U
# A+SFzsPAjHAiwZ4CcTj1koIdnRZMhwzXspLivrrxze2+ucTEUHu6c3HBbuKrkqwlfYpmygsKOaUM
# 5pcGr03dENIiaG1HGMgHB8infPwdV8QFhPqZGIPsPKlZfO0ly0wXWXXCLKB70MuWT59sVF+PmW0B
# YPnKgOGAB/kE8l/8T2rj2HNKTwDkecMeBvNyYsIhCxFLQwYcZ3h7+iwOtklhLsoKMAJDx5gQzPVP
# 3dmuyclCGxm7k77kKXlMXZFxs4E3UGbhuQXTq7ft+as+OlsfRk0SNyvUOWMAGu5K+FBngo6/ukKR
# /61ySlq8qoTOpYsMTrf6UqS48gCA3HRimg6m0FbL11AAUqk2vl1cjpVelxVG/QcYZly2ybs6JEam
# UQeIwGFw+G8XrSs+J2bqg0e2ErJZcIIhjnDasxej4kwbzANURCXY+3olHFxjU/pMOTdPaXMXIdSR
# Ft22GCEtC2HgmDMnl7y6r36W7GK0KWl/APQmoNUMBS1uBgDIGA/CCj01DgSv18rcjFAs9NPjZ5bf
# 5OghcFA6p7AVLtyD3GqjiLYi0jga/s9xMGJ5InSOcLloWlLXxUvOKk2grMrgPZX0hFwffUD3Q+ED
# kV5rI42uwE6Hm4zacF0FP6ALucFv0D6hZoguYFi6kc5RynqZtHip8MrSjQvVYJ8TshdQRYHJmnIA
# lld/OGuC1gO2knOGnOS1AuhlajeD+4/Kn9lxvJ16q7DG3/TiF3Pe+dtrPPHmvzqeOhp1/XW4UPMf
# w5kxHRkS6qcR+ae93z/enVNCshWgNtXG7/Qi35dD7HziX0ZS7o8w9xtdlvAJXuwMVUViUXv9p29Q
# SrV4PTJD2wjUpC/kifK8gsKh5at6faMqnACIEgQzhSnciViHNs/RWMFtUEb8axOuh8Qw+ni9PwSG
# NI6tzyz/nEZTKZDGLt+qGkJRhub+6XCz4p/9chPma2JyRa6j+GeAoODs178Mf4xsFytaLWwxlKRF
# MsTEos0N1e5f1jiYjJezsTrb3qUo7MOvRNZSduKsIw9IJ4dK7mADBv9ShyLAunSWny8ped2qBpEO
# JnvGTzr/9nk4jYgwOSQU9zftOHKcBhan9YLGlopE8SbtGdQY0dIrpG8Wgyp8+qtp90Jf51HSKG+b
# CXg6Odrsw+g38eMfRZhcz/NuR5I2JPS8maAL34XGGTRwIATthvIQQSnQrIUES5fdCSyCtffFXug9
# imJkV2ItCuirf9GcV8OKn4ykIAFGDGl8OGrt7WV/6TygPZQpwCTqBtjBCAj5ljy16InEbqmRmPz+
# SvvxcUl26knJKElapl2lhcXYZDuG7b7xafZFLnInL9paTPnHoJqV1pHdDy8E2/+Za1fJELHByh3v
# /zoejToCUchlZUU59JeV2sLFPzPaNGad2QdCHxalqRoWobSEZk+5pdfc8e1xDZ/1DUgY7+ZxNEeF
# 654sk5iW3VxIf+DeehSyQginp28cMHBnzPuQTfTb9eMb+5paZhR0iiuF+7G+XIL3OdGQi3RmMq0B
# DEb27rdlBV0mGezt07TeUHG5d1ebYEZJgnId2pmERtJfd2clZendFEk1VPzbUY444J7rrbNKAo0A
# f98JidLDFGgu6/aw4uaASpO9+xxaKdTGtMC/UZDahonpZrwp1lpIIMEoYqvb+oIepG0T+fGWt42C
# RE6/rMZZXyhwv5JmQb+UyMqXDDuBuXV7i9JnmEXc1Fh43PAsEydSVkVi61/miVgZdCiYSPnJvWRy
# Sy4G6Mjfv3XB5ql1mN6XZ7001AaLkHeBYpELi6WyhGq+0LUbJqUatnEzF698ee/vEuXdR9A+WujL
# nmFqp05jp8Hh9uqZcM6mgcekBjkXl2toJ0PqJKeusoSQUcdj0N2cwyh+LT6HhZMmnfLJKQMt2Id1
# CfbCe94gz+URtIylIvS8lAENJaHOxrVx+YvlxbTO7rxbSSZloPFd9BVSinh5983TgWz4XnCSTVvs
# s4dkHHvPmy9afikyErYrK474/i3KGVV4xIWUHnxdEg7Ptj6ugz+mZBgcv/TEqnCXnTAts51ZLG1o
# seXUkWk8pMuIFM/Sb7QvTk2z/MnuVHNiHkATDkZqYqiJOH9W4y6FKzwNKsUH32R5R8HiLDjCWkz7
# cZhhyrHFBgBKy8PVlIPYXOcxzOBGPR/M5ToN9LiB47UBdGB7C5OxkpBiYWMSoi+6QB1UWPgzSea1
# KG3Nh24pQtaCNfNrYUZxaZemrFHO0xQEK+bSZbJ1JGKllx8hzbOjKRsyBcEvJYWpId7ffKfIg0Ww
# Z3tA04Uo4mK0+vusGonJWIScMsvnT2i3JubtVmHEBPwR/fEm7rqTbSO1RO81jvn2ZuovK7znYQv/
# 4MJOHOPr3Jv4eT7Fdt0Nc8W/JkaQjvRF6qHSS2MagXR08+gsQ+A8HwIUzh5ApfgaiVlcv7y1CL1B
# 7ve6ynw4TjyQXczuEcCgC7VgFVEwFaTQNeMHdr2lVWAvzmOHlrrQLMtjOJj9VCqPp69kQ6O12J5F
# s9dt1cUw2d+0U7DzXmEJUZJ275PvoFs1fZ5vqCsnPnDqfS8rLG2fDiC7Cbjl3W2ozBK8BTIlMkEx
# Qw0p+KMFtye7V/5uq+I+nhJSgLM9NUlHi1XRsgu5hmPMqo6WKDgA0CJqzxltiHOrFc8JAiuJ5d4o
# 3WvNRya8bxQTlA8xQodoMw+kcDg85bu5iziFDsYtCJe5dTbf/2Mj4AiWPYXKH3OQbSiwFplH6kwK
# WpxYeWzha/YgHTfW+IFPUzqnrkgGT//DZVCi7MrWWos1ogWtOHqGYBr2M4YCzgBUX6gEdjG2/esX
# +nRkLO+bt7b8+JFhXnR2dGnq9u7JHYfVAR/2UY0jsRsnNeUC18C66aOjuFZSo7Rvasgdrpd27Zo0
# u3YtiamFoHMJ/aMzEXE2UXls3Qp0GC09FWIBTgsfnUgv12Dy3bQCbT8JlU/rGYM/8HvO69AIeTAX
# 4lJcp6AM40mAPb3VJ9s6ElOojepVpJFWgpfAMqzrKsZHWOgK8hAZ+rykNk/lE1eF8Fjq/Yl/k27V
# paUuc9Hm+V7kWSjogSlYJbmmzSTp+xm6jBcwAQMx5917mCam0DbLFR3O6VdSz+PEZNNjtbAGkED9
# Gr0eEudsdi/4hT9+8wPGxGOGKKikDI8ASUGpmjEdHFeZuxpEysY/XhBYc1nOfnZ5autoamYpoSdg
# AzMDlmRtfO1POSLWD0mqXE9ke8t0iHSY3rslehqYNTFr8VEgsNq+eW2Fh3TuFmsA7CLf98ys3E/P
# SEeCq2C3Vk8eQODbVxNckr1kjOEnFnvlVYd1/+Kq8T6exCZYp+onTcWPfL4Dto+quXZ/Fhf7iUKO
# sozuZCCx9eIkm0pZ/kdhLfMNKesRmOcuiu9l3O1TjUcprE+HHW0mHkkTiIh4DoIRonfvVgwy9ebC
# DvEgzNI8yrdA3ESH8v/GZPAM/tgXskDi6uXiQQxR9btvV6SxK2LIg8LLKUc44LbAgSCGFP2FDhZ0
# nRq8fCfwQixiPUr9muJL+kOfb/x9FAsOLr4NT28P00iFsWLmCAz93Sfues3ZcXx7pG2qq4/G8EWQ
# uX5Qm6ZhcMrgd3724ifLEi2owHUw8xkNSN8Zz4Wt5hlMrqoJLTcCW9sdAASo3dMA9Db2WVs8jJyk
# 6kOvi+vx05CTiFDeU0mzT5r86TPHpRvdP9hqqrVDcMwqUA8z5pCd5P2exUH1ON5HUHW9+XcYN1yM
# Ve/Z2khqz+2qXtPVJxj3194Ak0ZZOYChOaB0xqfDCE1OvlWWz+1gLj/xQp4hk2PcYnUggw1lISFu
# AJSApW4aAiwjDBmvnmnBAu9ygQLScePcHwOffK/W82O6iX2bdtU/x78nVmLumaUhuy1cwaVbi9OT
# bTFe3QQ0HzhnZ7cNbLqnLhD+DGsoN9Oj8+YHWAL5Wto/zpNd+NTXaPeajEsaRpxVI084Ew1xR1rB
# ss/+hZi7voRU1NrSrZcGap43o/crkRnL8GuXfrA6YB5ZqsRL3OYZ5jAoGRV/lQa99pu42v4awS3w
# IO9lIWPHZ5mniAM2SmIA2TCTD9V524w+YD0XGQ4blxgUFiHLRahmJYsXHMY61H5wkQnFg/CNehhc
# ybrZ5MnOKV7OE830/bbUUZ76/q5mbc52bu1ZxWgB3ThBcLun629YN1F31taO38nVxuYvdxP4Hoxa
# GyJB6u+3q/A0FFY/8Ocs+J2l/K+2XQs/p+dZq42MKc+WxVkmwNCSaKngdIOSuWwcAYEW594EB/e9
# vNKB4sg+KInBLPKXWN3wg3ljj0+vrhI/v26q82Kv9A0zavRe9lM0KEXVCDOG3xXj1+Hwz2xE292I
# AA9hyVZdhpPXvHoR+LyeRVs2SoNJJPhDUlkAwKmicB2MztU1Qi8128TzsQrz7NPEN34c1MrfbDvT
# JNxVlGXS+AkItq+ONaRoDK2j5nCFXm+fijnfPkvDN5g9QyqPa2jkexg8pKLk/v3LM28bKm7XK1P/
# YQlSUo3JIpmqu+3lgUqtMUKeEQxVh8n/xWv++fZMdGSzySnovQIq5miEtkDp2Su5PTghXNtJlIBZ
# kcfoSPMjJ0zstN2108q7LZorkCLQdP354H4PWQ5ybsYz6F+5Rb0mscze1zD+gKkDBt2OHHd5D8Ey
# p5WRll8ylhfAfaKPxu/0Iip28HUMytqnRsxiPyOxBnE6ANSfnAXl/wjkC4w0i37LkX7RFJ/eqzTU
# +aaxnoZOHINS6QuzJvs6Gn0HSxWCRrRapZJSLTDF2Gi2GuM5XsJXTg+UuhzsXXdrBWcKQjWk2vQp
# YyxaLKclqa+l7bMwV8e+ASO0hOug9hEXWVG/1Eva5va7eJuutDldM4kCfxGQJS9xYyE4gqT7BlNh
# 5I+TmCxZLhaTMzxXyHbjkvTnuzwTe4n+yr0v4ugnDAJEFM0XjfMWjwMz8xZlVkomLtfQalm0DZk6
# uXxqe7O39EIg0uuSjN1nlichF7BBFS7GYJ9CgzbG9G5eAG7O+hXEC8tU5/bFHSsUZElAMow7NgIF
# LLPWWH6e2rB0iVNxVpuAmxr2olPQf/CbekZDUng1y3WThmcQSvj41Xx/m3cq1tKlZEA7APb3+BXN
# O1cpWt5Z587FlEMRyQzkGtPNXJOShhzp2ycg9deXkTJ14h8oDF0ZwOo0VBlt5RQ91sDrh/q/SmEK
# XQHgLwrk0SbijjThnDiVe042oW7UQW2j9GzAQa0ne8YV//iQC8+C1x9eNllw6FJOhi2HZu2old0x
# et0v6f20v6LFONdYyNHU2tH5ob5WRVM9FQ35L4+vfcZZQEBdF4mhGpz8Jy05wk9gC3AlGLqH39RB
# qpn8q1nqvhU8H6DYhUmb7TuUXb8WwbwJCnwhO/eeWPLyFQbVfBmYiyqZH0+Kp5gatlcx9e98CZf4
# IofKAJN0jmFtsOpFYw4f2a82Ilk3a3K9hSe7uCzbXe4d1EU5yqrTioiv0pIPojBsRjgRIuB7wXr2
# 4n1TKGvTAgwhs6g3zAXhhAiwUg9yiyhwXPwJPZyEwdlgy+5sb57N5GaThS0/IXb9xEgRfF83cKdh
# O/+vP1pD+ArMJ65T64JTXiiLksXfo9iXHL4G8T4GvivPBgO02x0pCFgY+Axy3YO03RM7jd7ekBY9
# 2uuhG+eFft9vdWjRi7ziJ4EXys5P1vEgzFDXFpriylWk4AfI0+6baKoY54FbtnLAVw+gLS9oAP6S
# iXqM4aCYQs6uMVuhQ3QqX/nU8WlZ3tZQF4LXjB0Mr7/UsRQuaXI4YAuKT8h4wb8RxZw8FcwaCn2o
# DDbRsb+t9+Yw1fnU0ly/nmws2q6KP6uxtp2UWqF45ifP5RYwmF6FBI2CjshdaTzgi6uaogA8dIaS
# umVE1cDWWd7zEBmYjDKpgnqcxBF4Z3bRQ/xjjUkY32k+i/Dnww+CSRdt6ByqAqT3wrf7OwaZGLV2
# KfaYLMk9rG/0vBF+Wvq0PZDf+EJUbtzcBeoIYNSA5BEpxxp+yH1rwCuSzphGhbyKPpcw1O/zcSCg
# 7XivQOGxg1eZcCa7eSs4AeZ7OgIyclAHVqI3zq/ZHAioTZHTvsYRwk/i1JzYxZY0BCijXRu+sBOV
# Cj4zgjX+80KQiYl+QAgikQsrqdWsxfaJ6dxgTNwraDDfTbLlxZZdLGUxfNqzxI1QCW0CxqUrwa7R
# Ye7dwtkRPOPGsJm8xip7tvW2UM4HsG9RJYeACiHu6XcyMDjpw9NqesKeUcTeUqOOeKQoe6lE318B
# w0QZb/RYmWBVjj0SQsYtGViUzV5dBK0jTAlkFOqXlYtezKjNri8IGgKG4k5Gobtmt5hIpbBhn4Ay
# jdQiVj+N/6y9kwTCgzBBY1VonOV6O5z7g3giz+DAPo4lyB7ecZjAx30wpAjOjFS3AHAIyl+F0dEY
# 0nSJVhevR0ZZlsV+zB5/nFJvu138x1AihrPU2J64TnfG70b5dtCixC0pc6uK9VNr8dAyT4W3lpr2
# tgbTyGMU2HNxZluX5bzhIaO98r52ZRqhJULQVQ6srNCBvR6SfxxwWBydIq7x8hJQVd9PUTqit2ME
# aEV6fUnciRawgpjs7N2AidpFbKcSMJcs7mnyPXowWcGiSdvwCH3Rdu3CCoddl8fx9y26Zq/xusnc
# AIdiwpPdMG92xgvUdnMg1Hb5+F5uzRLJvmC0g6MXcOrcyCir8MJbu+90SwQaGj5/7/CqQeFOQzTH
# zpCQlGkj6VSPay+EKxyL1xBju8viHj2gSMsZVCWTCLacX4YeC8K6p3/ho3O5o/nxPSW1/jEyNOWG
# yekA/bfnqXDKnGgWQaYzqrKLjiJBHUpjl7S9qxLR1m7vKHQucCRVTJhCgD45gdXQg40MCXXrGAD0
# Vabubzmcv/eQs/gKifY+2gKio+BP4lgFvkOj1k56sQPSqTCYS0an0+P2Vw3zfdK2IaE/JVkOyX8Q
# 64xGzXjcoqOT+s6oxq5KhaBdeHPwWJHmHWPWE+l8K+miMlsriiyjEN1oAfeknfe/q9jMJeb6hYrN
# HG/pEtOw8TMjd4mRUsGdMlAoXq2CYs47lKJ5Kakz86ihdOJCEJLo7YnLD0wpmC7fsLuecH47Te+Y
# eh5rmqVp4ll5F+NrN+DyqyrIdgknv4MU3ykLXX8WX2Hw5Hli2olB8HGQ1A9+Ko+b+tv/ojdM7prp
# hC3WROslUjQqin7/GDmTbRvaLpaU2sf8fVyYzEDefOBf/oUy6QQheP/fb1CEFar8IHviFd52Aofw
# gQYAjPpmwQi3OAr8Oyu31YL9DGQPl7jsu4Kcuyipr1L6kuRKsfl3oosqZU4yWAkVYh4NZOMYz7Cu
# x4Tz82QeJvoXPivKfmu1O9vKVNRftUVtOd9mgKzEinzU2ZfKefKT35WLmwBzFoS1+zZPa8Xc3PsE
# 6MJeLGIKtLkubQHXxflmtVoYn4wPx6l5HB6EPZqpQm0kqywX11ep2Nhu832eb7F5mg6dJo9Nitpk
# b/B7RVrH2o2EvaBTLZ/t/r6Xyv/bN6Ly3y3mzvZcaXlBvhijJ3VZz61odtP2/X8pmvmnI9ChpCQA
# 89DM8p1MbCq+QIweJI5lP6B0RKCpUVgYLk1+jaTLEFOQVS8eqU0QcdHuxVXF34+fcrD2YHh/ShAm
# NqI1DUdez3efrBs8JPZ4O1aQ2mY0qKRAkuD3iRsWGPkBPORj6XrSCtV/4j4pZ8PNsH8gHjHwCr2S
# MfhoCvWXyRkyZ+jXdkBCoKHgxdVs4uc0JDBKFiQQVWCo9RzW1SX+/vHdcwnWHMs/4UJQmz5eJpxQ
# vyjUzbpZFc2RiDP50UwdJj817k9/G7ei0bhZaaZZPLFdSfCvZF2KmRvlgOWnZRYkKbePfCg8PPhZ
# yEoFQxufwI+Eqj2fe2wIcni9j2NC3mZ3isAFVpl2xGC8xsVZAAWmCrUCSz5CfSF8RQ4YPTNUapEU
# 4ePreOl4GnPrc0nAEZN1XypdIj2Jrjq/PcZT0QhmDj+5O/dK/qva2FhovOVMQhtHFnqhSrns0hWO
# OBriR2AvqcqSBHliWcVprvjjklCsZWoeShEJofCbOkf3CSiM+hre4VwXz+CJtul4jIXDv12TJasq
# G8gBT3LokHuWdhbg64lT7aool4C+k0XFmqMStP1MgItWqctSOZvjEpzonv8AR14mjHnpKNbtX1HZ
# tV9PKlbIL1bLyO0z1R1en93eL5XzbpZ5pDMIihLKAf2drKX6H0zMOBMLnIccvUWQiyACrHJr4/Nx
# jTV8p6rmb1CQ1ud7hJaBkWSnJjVvFgJweXPhRZOJYbn3iP7dswKzIUkZ04Q3rxmtiIVo6sNrjyQo
# WteVjAufVetSNlVFm6dVv0yynAkTL0SrO1/gBQ2MJubLJ3g9prR1gj5D7RPWAxeZykVQbSuKdzXT
# NIQE+gjX2lT2uzgQevTm4mAyruPOOjAma8ErIGhJX/B6Lbvj6btRQ6r6b2K/6DiKSEvZRom4Hyg5
# tfvGxzOrmPMFJ06eJJYHKkswNj4kTfha0oKhz0p+hTjTDOtkguI8cVOfxgZMqrSXb7sXgozgjPPL
# ufc8OeAT5EXK6smP6U2CCw/1QabbnKL4NpzNrIVBuSziJJjcx8Ienv+P85T7wGRmffA3eemaKMcU
# nTbJDDk1pghKsFNUmFTYvkEzjkRr0MW7g7Ho0K9y9wHOJoMnqErV6Fh1xNzWgQoKk5OsvSOPR2C4
# 9UWsKFcyHX+cMbdqrJjCqUNNZCWeCdvUN9fVkDd1ornvLtzj6cyHjcRY0xkzzKjB9ANnj1KsIGoB
# yhOLUIbrk9CSnbp1qm/VHaXJ+75eXZZfFyETd+RuDUewcMyGLAKD01/tN9ttHt67gjx9BdDe27s4
# RQ75gX1xjcGqSdgXkobXkLeTnrzxWjSHlezgrRvMbuzO7Bg612Q+n99Y/6QBpZK/JesTQsScF2Xr
# uQ8DtIqebsuUAs3l+FXHViBj3zwPt/2J75X72PYmzkeoM0PgokXMiUf0VSgRgbNLgv7VKpjW84aL
# sQWN1/hRgJXFVu2XZqSHY5KzFGP1Y/KOInHNKKI4vvckUikYZVpixTnfO1gEPr0BVfGmbpYmhSd7
# KSaP504yu7but4btEDDmchEOoKoRnx+MMdx47Yysn4zruo3CboI+w4T3eHexeHRKMZpP/BTGVsNB
# MFooNs4u/Rx8MTCP/WGYBz+m/F6a0vFApGOccL2p0rMg73Yx4kpuoteECWidlP9isHqbPXw24Cvj
# 2MIVcMSMoVTSI2QoP79ZVVzPiTxlBRVaK3gN6TxVWkXAOMb3uYYh8DvZ2E9F40JIXttYaWpJ0uSi
# VW0N87zvbFcRoRql3OL5ev5RpW3qZ2mK67HnHeLSW2+eS+rl6Q+PiQqUVfblPs0E3um/n7T9hBm0
# j4sy2x6D7k7XLcBnyh8FheO5gmo5TeNVgnLbkAekjKwAHN/5npnWuTqNuTx3m08C9bFf/MKzn1TW
# pM45QvOgajnGkNBSsm/di13pVbVm7vtegS7JfeCTGDUeQpe6aFdJj4TcckI/gQ2CrHbNIJQgDkXN
# QrTlqA/dLtxHkB38oUFiaTjpcd0Xwtk32nZvnQRCpjhvMQ1HwmL7pRgnPEkXqFQKlaRwmcqZ8SOL
# p+fBXDyPLFMuccrxJa24w8niUHNDZZ72gQwhnDytyDU6aEbYlNYirLoWKuG5Dkv/WrDpadpdFqDM
# D2sRW5VTWY6/tghK7t0G4zTOUGItORKcXbfUptb2uL3x9poej+aNLn6lfFnJtvdpDGUyVrFIT3sY
# usQTTGVR5p4dBtuuxhcJv01d1CVXd6KspLz4B6b4KACqo0xDYC3OvpYvn6uZxqd796qIf8iBPQdQ
# sf8X700P7vhYnRCtlKiLmtxcplE+Np2tEHb7gsC0mbxrmY7JV8i/RqA601BIZMTZCStIv0zcNxsO
# 7Cyp74dnIRvxmwpRnhRrZGmSeXLehe7xXGJS0F608onw9ApkwyImQ4tegd4AxCjm8X/uw3K31kNR
# KKxl0RqOP4/DTehg2p0e8htDuTUvClA2ArXp6DE3uyPhyp9VG2eyRgsvl1IioFpCHq7J1uMmkRcn
# dSWHRwFat6zdvohzUaRMedTv6nEogWubQ5K74fgMdC4y+iEWHy2U2RBSWb5qEIUAIjkM58VtamTf
# bWBDhI89cZ7J+B6n879CLpEPnKLpzIUS95E71Exqnydre4/x61mnjCpWk3atN+H0wyTydEwuzxvT
# nC3uBz6km2G2X1/njI4UYjl2cQC/BZZTkCcH6IVU5/MZQnn9wUYEmPxdpl8Un5jYH7UX1TBT3wjU
# 5Y2moU+dVxT6xYkZkdJPJb3NmPi68g9ch4xZLbws5mykDxqqPmGHsfqyfYt0pODEKJdzFLlP5Nsa
# MI5jH5YAY7rG4H5zEGjRO58978El4c4VxQ1an1/IvWx++VlkMXGaZFly80U3Ee1MSY0VLw764qIG
# UhJJUHb5In49cxRXC9UQGjrpbCFSWTzdenMJ5N1fH+5Rq9W5NH3SiiQzG1+uRWEamknjVv8C0hjW
# Rs2W814PGD4DaBcciLoGu8DglATSBloUP2N9UCgFUYZnIwSkTS1+SiH3G9oZc97u3ma/5oU4mJfx
# lUgmNq06TdfbRBud7n3+FTV2XxO2I7M3pEoi8zIKfQdkp+khoKWtsaQtq3VcTmMRFqoX0/QW6pFz
# e8h9XSoJ3Mzs/U3hfHaDieU/lDtr76gmWW1owP+m+GQvmgRcx69niZI6X0VaQ8e/dE/qLk/fFEyQ
# RBOMpW4BbQnBkKgjCPCJxI4Xgint+Aywk/Y5M2zibtQ5+ZDjpostZ4f1kM0DLhgshaYokgY+Rubz
# HevY4bF344W0bI9h4gCHK+e3gTmW8dInwRwElr5HzYaSbQqL4oFMRIdN72Yagv0QPzucScRCampg
# obay39/3Q5JUnKBE5+A2RX0jjggHmNw7bRi6+8QDM6gJHXVpMMzKzMYLAJq152o86VpH1KfKiqx/
# ykzXl1B35f3x65kkz89TQ/KjRR/JS/mfTdr0EHqUjUa6bpzYRoA0MzCVUHE9hW9NGHEkvLrs8JcR
# grLDWaTB2LXrAWVXVgPOqaf93n3yyVPU00XwvWoyjjjh+UlcEsukyK2jI6NnOQlu6qwvhXXuCday
# X5vd/yXQr3WP7lr5fC5t/3iLw0Vckf9888NjdveePdUA+6bbY6xdDPM+Ktl/czFNgL8bBdWZSKUv
# 6NCAfQBaW3d70iLyURU57Ci0hBBRAr4HYDUfyIxSk3BUEc5VcJ4bfArqfCVpMjKOR79/BMcOmczM
# N1OT2hYlF3NScnzOhrHcDrGa/CiYwFufOpBfCW8iJKyYGtZXzIVqyunvIfmkwapLmQ0KqFeH99tj
# ked3HoOiBqND2mGyHTCrtqwcS/L0TzbgkyP7k0GHRFlfed1K1bTTmlS1W2+5qbno8+r6Mox9mqzh
# tQd0sgGh3GVtfT6+IQGWzWzMBW/dBeCXxj0m30IenqNgkvJzW94XWAb2A+M3cDUgBNJKRdO0ABYk
# dFU04nzeesZpyqk3xEFLlPsj7JiKXf83ZIx8Qj9ZvmwEDu1UnImhGtR4wBE8gTIk89hOvXxsFCR3
# jmnK4zf1gPzTVRWEAkUcN+NSsFPPwBwY2hwoxiXWfp7gSU0sQSIhrCpm3vClO3Pm1713nk7TCxe4
# LfvPCtNWaQM8l8xkf6c/7MpAPV0b6z54NBwLyo9Nya85+3mnGrB6uM2r8qBIX9A4qhJXvwFLv5bB
# Sfhvi6ZsIVtBgUMcA/2TnYeCnj1YB7r0iNP0tCJ8424vr0q7wQkPLhGR7bq9QEg3XJOuRfwz/fIq
# I2Nowmty16fyggZKhB8wvVFewGqHUHr2uiTWc+F1PxHSoQSNX88mnG9dRUqBrIL7yVI41JVhDL6q
# +y5CLuirdb7y3nxD9osMFNGWF7/DZGW7a13IX1nfmG7NtVC8+9FsRnMq+3Nb6WiWwuXA5E/dmuwy
# LIl/xuvvPFfllS/5A8+Uc108IXdbKXY30O1+4ryz7aSG3Haj1v1LeDES/hT1Sq0aeZY1gbTmjAqH
# ijdBHJclriambic6F4jIdd+Qp2E/aO4g8q7ohdXJqdIRMF9VgP8dJlA8xllJHbhc+TeohFdWCbIm
# DQBhx3I4LwtZI8+vr26TO9oqSSsQ7XJ0SwU7dSUdU8fwuV8hhNOQk7UMjFVHsRZc/1D+tf9osibL
# /kbHBefT3Le7TvEkvltQxa3ZBfcWjR4+/sojGc/gzbmct1oVPKibVF9K3sT8TXbxpxtZxOTVcSfd
# QjMF7INv9eNQSHTaPkAvnpbZ3TgCp4ppMif5leLy1Y53Cen6MF/CHr7QyGR7n+iL0PasCWRK0vhk
# jKhhEsF+xQ5g0tNis8BfipQOBpByUIbbyKGHXFsKW88jXGVh/izhLkKCzCojYC9Q74BsaE1JSoGw
# gyNDBMmDW8+n+B3CLG1PabvEj4yK/8R+tQtpFcBFH5wQIzRoiobRtCRPV13/jTza/6UsoapWFMku
# PvQD0CctPQXrJ+SCfrppCAwOZ7Au28aOLRgoP9G5me8ysJuYKUzFuZM6lWDC5dGBiOMTqDNqU4OJ
# pbAjGgHaPoFgkFA71qvLEJe2MpF3wdjvBv/uEJzs2GYBxA77+yR08DXkhQpCHw2l2p/E+Kg3yfZR
# StJaZHGsfgLhsdEPP8M9L916IrRNosDk3F30mrbDPP5ubNwbsXF94bK373d0eff0L5QuLHVwBcvR
# xsXXHh9nk285r/bSIs8C/03y/q2we8H4wHf4lViD6l0c61v2Nh0dUTP2qN3fwYZNbmVrBOmK00ig
# zakYneQauKAJ06/dMv6JYi0H6ZW0YG1fuRSAxuwb9AigDCri8a1of5+I6zKmDw1/AfuGRXsYTCfi
# o96GE68r4nOBQ1cqODZ6ZCjYx1p1NpRSXn82OEVilybNVHpvuqJ9xEsxr4o2bq+kplH7Ce9qwBcG
# hw0eOkVrUEyUjASGs1ms00IpFk3VspRX9t74DZRaD+88G21DnfnMggfkhfh/X7iqDS/SgXPevNNd
# qdSsE7Sion3jVMxXXpFuUjMD7D90uoAEj5EhiJ15nAHQPzccUM4nIjLW4TOVCnLChLAKT2LZOrMq
# wSV81H9JazZlJdQpgjl0RfydutL3g+jJE00QwnCf7Mcmv8IPmxPKr5L6HB4yie8FycnOei6L5LX0
# EXTmeJcQsNqCkGQGBNBB/ezfcIbS8FV/ciPhA0gkREI1om8Im0pliZAdUvDarof6FeIJYyg7UYIA
# 2xEEaHjss4dNRK7LgtRRfC1fRr2SyUuh3grQSTJA7TjAK5sXuiIlvr9i9Vb+vKTYRB6D8r1fDhom
# L/YLOdXjo14jvbUpKaFF2MGagcvTBBI9T21e64zNleXO1Tf8YshjSzpnCA76xM6GIZxlAhboEkVO
# KB4J/SUUJ4SvyAjA5AIJh4XuTW/RudQh68FJI64EH/6nq9zv/0vt9GGIgVHv2xdvSlGmJJXesiBy
# sssLu458VARBmNfUwPm5m6h/fRtUq9n14ezJpZOmFYXtEg54QQyyuv3j5auYtnXkn8pM3JfNeCNB
# kIwF5PMwDOy56B2TFGVKcikQVjCdygU73cVVG5aGjAbYG63eUy1bNcy5lcKP3eGOeRvTZ/GJmu8V
# mFwmE7QeU1XTdZC9L+gdY/n57tO/GwiwoWYiGupYvm4fPtXwix7aBLtrBOWzB9fzfEr5DtsPQTPv
# cRWRAGEJTIkElVai9i1VZml7YiFbVTelS8IySIRgdWHQdd+HDyoEy8sOYM9SDyKmc5VkI6BmYs6Q
# 83e6kz4H1pE15Sd5YO3YshQvlC3QyD++lH9uCBCl3YLBSLNt7uZwfC7e6zKyPo8Zopi6rG2mL49/
# OOHqf3uAPS29fSIqWZHnsDU2eutDzxvelMv//a/5L82zRiAjK9oBW2Gj2hkJvuFNEvc/Mg+dHgSL
# IxDBP+FBCvf0tyN4KPp/zqzAYATQf56IIDrD/z4/878ArDMaNBoyAAA=
# ----- SOUND END -----
