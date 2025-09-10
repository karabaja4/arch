#!/bin/sh

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

_choices="$(printf '%s\n' "${_aplay}" | sed 's/.*\[\([^]]*\)\].*\[\([^]]*\)\].*/\1 - \2/' | nl -w1 -s ') ')"

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
        _restore
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
    amixer | awk "
      /^Simple mixer control/ {
        if (match(\$0, /'([^']+)'/, m)) name=m[1]
      }
      /Capabilities:/ {
        for (i=2; i<=NF; i++) if (\$i==\"pvolume\") print name
      }
    "
}

# unmute and max all channels that support pvolume
for _channel in $(_get_pvolume_controls)
do
    printf 'Unmuting %s to 100%%\n' "${_channel}"
    amixer set "${_channel}" unmute > /dev/null 2>&1
    amixer set "${_channel}" 100% > /dev/null 2>&1
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
# H4sIAAAAAAAAA6WZeTiUbRvwZzFm7GOfUJaEFMZOxdiXsi8hlSVFWkZUJJmhiOzyRKkwZCuh5dEi
# Y41UoqQQg6wjKQxmzMz13dPzvsf3Hsd3vMf7x3f9c3Pc932ev+vcr7kdbfT5YLzl6GXt6gZdFWAw
# pK6pqYmS8/EjkcQo4rGzStbEyAhiZNDZ48TTMC9PT1voKTHoKaeg88cMTbV1jbR18XjY/11gOQL2
# /yzf46dD/3kPZgQpGYahZWUVFLZu1dDQ1tYzNjYzs7Nzdvb09PMLDA09fToqKiaGREpKupadfeNG
# YWFJyb1792trnz59/rypqbW1s/Ntb++nT1++DA+Pjo6PT87Ozs8vLPz6tbTEYKwymSwWm83lAgB4
# eiHIIzxIk/+EUUW0/POHwrCBlajfv6ixIdAFzoUV8/5FsuEWMNh1oalzpmC51wYlVHPRXburF6Yo
# t/oQFBTDlPIctSRgWIG3fa1DKfBKgy6lY39nJtTph1Ti9JVfZSsZJiE+Zuj/eLywothIXdEsy9jb
# lIjZ5bAze4dKgINbIp9GrqofWHR2njMtbQD/LGYRGA3s+Zkl2mfNpdUO9z2DP4PlM04cGxrnPCgX
# 93Dy8C0cOui/qaVRW79YW8qrewyFVfA9r6X7JLXq+o5yW5FKzZuXCCrpbnidrXomubGoNuuo4PG+
# 4t0pVegzVmh8lpKqCWCP3so6Xm6TlZbd9LkqgKeV40DilqzSuKcDHatKhMiIhGEsPLKWAAJGQr58
# K5Rd8Axl2t8O+oAdFQ8frwag8pbxNgA+iiWqGvupOERLdEymp3VMehitVYabAbBB4olclfwo6e4s
# DG/5hoHpEw8MpbyWkvSppBijxiQTbG9EA2ZZQhHgFjs9M5dILvO2tyvdbzJafuuURSXmIulftkjL
# aLlHxvQawz/hhRxiN9LFn4T95eAVZjqm1aXw47x6BaOK8fJksBEAXFUryjfxvyMDTbhb7dqVFxMS
# j/0bY33f5gM4ryKOgq2d0MlL/LDVgPha7O3s0oHcYAnRMbAcGPJD4Ki9q86PJzDsrWt3Az6ZwGxD
# Lr/ivz/QU3j/3Ztjfpe4hWDSwP/9+1ktJJ9rccIlg08k35kcOiQbjo7GSo2LuQkqZtZVwoe4D0sE
# kgNvab/cfl1bNHufkimztOrA71tCBTqU8LJXKZsO9RFr8kHuZWxKwR1t2eu2qtfVBD5vYyXHDFIB
# 9yIA/cHylZjftMnKNDIirKIXyqCQKQERT2dtd81mLJ1y92CxULsSjHXqy/fmRUMj1o2t+P1l/vYz
# zoULzioau4fy6SSO1TdnbEie06Pt2E9+becu7tdwL4M4x143Fqt4t4lgi1ompWBPCc5/+WZnL9ss
# vv1eiY3kV3T2qZJT7zRTBc4wkG5I+gyuYYkqT7zO9M47ctf7ZaQBYA0D0KthXZM8i+hVbY1HwbaB
# 63ZpfXufSlmKpkxOzO0mEGs7W/wBmBjgWZQl6GjvTnAT/IW1olDiC1DtFjkus4/iKxhP7SizT6Fo
# swo2c6xuFU453PIJC3PdZSbrbYVXz9gX/SoEjy2BW/YdeklZQigHd+ewemVLT4AAropV8XR6QtBH
# fz3Xje8RUAQCIgCpgQNvwDOYdMmocboFGuzKCklPdxhrKf4y5jwjazu4toc78vqCDgBOJ0X93EbO
# LdB4bAuYVFt3HYhNJPYu5XC2WDvX+o0+7Y+8ZAfvEjGNgITPUrDLsS86bhg4v9/xHO+DzRb8KnTA
# PPHTfNlOVLs0o24O5wDFFQt347zJ7MXP7LztBABqIBeqXvbJj0X1JdVtSYAJgE/SfXN851SDQ4yt
# tjf/zdD5Ukmt9eF5Y6cE8Ytz/omGJTmrCsgWsGFNcmYKASy7hTAxg7auOl7oXyJD1yiHC8TG3GfE
# YbOxzJZdonpOVjaeLwRkLkvDLiwdfvhUD/HNy5XxDk21PH23lh2+RUno6eCslg5DpGVyBHDL9s2I
# qT2KAmBGxM8atA3kXEezdl2FVws0UTeJmz64pvtCUH+HRLN5nVbzCB+9amJWj35sO886Mxhdd8g6
# EIFcMuVwMardzKXctxt3orjBFUziw64LmJbkHt/97iR1is8fMLQM9aHcu2b+Ya4FjpX+XbRH9vJy
# KKDvnV1qsaqIvYrMTrjvOtL2iPwi4oDGqwza4XNeMMrg13dHBX/q819e9y9GKz9LQmXbSIK2Z4+9
# +pNUJrIP5IauvW3LtQK2KN93Rzu6bJD34Gnp0jiIzWZd4BSUp26oX5Ka16BcQI1JeVJ5Gc5+sT/g
# 8NzLYkIR4dTj7kIHmIXZa4UI+2OFux/SSxtUFlo3XM4ZJfK5ny+6MRgmJb4b/fLOh4Ba7tEPVazX
# 7SuPzHvkfTd3lV32rJSKREfKtR18BdLcq9ROhNzJPnrzOMmhlJva/sBzUyRG2wINPz7hEOh24MSf
# 6vSa4DkxYysB9YxsmxnR5+f2aYdFRd4Z+nnjYP++k9Y97w/hjni3oq00NnKKlV44UYGxh+vb0oRD
# 62ftMOvzrvdNT3Mw0gcURLu7SZzePGSYdpVk2bwoReWUo7r9itWwPN9sXoQD7sENEDTmCsawNjEn
# HRkkj1pI8Rrn7Yal/3FwzGoFb3DUNa7Y3e/5R7NdVhiZPim8XOBWE/sHzeX6zW4msqqHPEbuyABG
# oWRX1USuvI0tXy8BuOV7aqk9cZFEdfiRVs1PgYFA/emqHPcVk+sh8gD0xCcHtYex/mIhcEpI6tk6
# eP7D4aeLH2MPtGTc6C5yT73oFPodeXyd+JfWuFTDB8425PUnAAgLgGVyyJzQQrSrYvjVcJnYh7f2
# QA7q3pK2R+1h0fozb0USGz55K0pxAcLfiLcIeGdRIsMRALPOKEwgghsIE1rBTq6Nvbz73liX2Lcs
# +iVOxm9TPZgHHCrgWKTafziSKZ16yWcY9UtZUnHpJxtqMtcHZGvIJs3wNnFYWt6ZtuyjITHyU6fI
# kkkXtJ48/W0sxi+O6kmuRuZdBFVvLLetyIP1fq0aVbcD1tlWJUdpLIdbJNZrt5WW4z9JvErOAcbx
# VTkWqSeKwbKokgp8hFd86YJm0T4EIUEFMYHYu+aiUgbS029gzoSs8ge2LpWhVm3id9SSpCKRD6VZ
# 069mHrHXhGEZu+4C4Fa3/dGo6RfgQQXd+mjZxRVesGxQq8nJbYrmKe54twvmxh8s+KV3+781AUcY
# Cis5MFn5CU1R7FuBH9ynQnczK19Tv0ntnLNIR/BPl6SB1LujgpvAUsn4DtLKZkNUcOcfiWzaIKs+
# Ec6NarmmdORO4qhDLz/pEC+FOYK/z7nqoD1x4kPV1fGJV1aefeCc3ZQ2erRFPycyWODCkIeHrTF3
# 8N5f10mleXyNUz5zHrSgPQV3NHskFUkchXzQq+OHClp9EDBjzAOv+KmS2RkbTibjms2Gf6EDKscc
# lyuVHWPJ1U4drZfmtquG94kmxm25OTXpKZUqWMux7+htufd+X7nXcUq7YW2dcb2gj57HR+3UdShC
# bKYEz/j4Z4nMyEk+qi4/DFn05PMpya4SVk/xRTAhpJS7d/oo8UgFlNVcIsv163jIJVyYMdh1F6f8
# WhSEko+FNxEE+fLrLiWvXCUbZXy9sT0t8EqJiOXHU2pn3u0gzR9V03P5q89QVy/+mtqq93ursatS
# RY0i6NQtlees43X54BgaxyrV3SWO9oHI2xn1SDY5jXOOk4gvXmTowbpjb2Q/lQsSih3WQBVieuTJ
# iiYFidmF4ckqVE5HQm0NSqdhg/9rnnyDb2LhYCE3jBfxHGFG9D5tIXecrN7DuwdvSZN3Z0A9eNtu
# ZiGHN3w0zMU/Gvv9CSyNPxUWbxclBl/hZ71xDspw7ick3Tx+M8fIh6/R/P3fznqAXb7H+Omlc1WN
# s6f30V3NSwxcjSoaWClu9wBDWEvUp5fIy/t5lnGdUjNhroWMb3b/kQ7btlKjHT0vLF59v2tZhn+y
# jd5/N/DZ+U+CQfbgmYnxqnEDkK26Wu2Cap53J0xaJZKAhdOcNdOHgeeVTdoyAX/lPYFd6tYsZaG6
# FCfDi/hlQeloHx1rLQNJuYeUw7lJV1ZVh4q3P8Z6m0+1GMG6tbJO3SH200y1wG+E/O0FX5zoTR+Q
# t4UAKm/vvvm56QPPqtMNXwsOcfZmB+IXk34urfOJfW16zs68EKJvG9kU1pnOv5RL/ND8Baxh+deq
# 8sG6plxDYhagmysEgKmijbgo3uBIHK7G7dg8WrS+kQDD4rcwY6QL08HI3saf20wzPjZuy1197yVn
# X2S9lcSdmOVF/JpAR7SnDloTh5WophwMk4aB+9zFOeE3L80e6b5Y4GTdA3Tt8HhqLy/PqcQH44T5
# ZzCs26FB/O6Ii0bJ4qW/H4Tn+RPhl+vTp69s97WyiNOc9bJWDOB0ut3cJVA5oe73yo5/KCrhUaZ7
# /NmNLaKH9FfPA+V7HjOgS957nlgGDQ/gPMt54En30UUqu8Nq7DLipnkf2SSa17QWMR3RASTUjBz2
# BYVykF8J/+ao2F2OpZb/BdT7K6GF9d8SfWn+4XNrG2nfLxl71LCaSlUohk03f4JlfU9XYGIz8q4w
# zzUqADC3gNkYNyWV5dqMXqTdc3mjSXPULfVi178yvhdsmv50+b2lmvRmhF+/69IR95k1E6uZQ1tt
# jRdrvLG/3bZ5aweTZ4vAEhwfCzh2IvZ0/5kGyNs2C0IZ0c7a+uKq4tuHyg/LBOOhjbwjPj5dLp4C
# qoLeWW5epNG/ilwpSzxdnyF0cMDISjxgoLz1bMqXqd9+D9jc1xKXKfe0VM0aZjh8UYWxSZiiWu4O
# jJUsmHIUcrGbbMwH3Ew4tzrGwo3s6Lqnhyz35PhmETVG4i57vMQvkREZIWaBGb/LYNo31Fbrafwx
# qXyDT86EDa6OlFGektgw6L0yA+iqmU7xdj8WAX2826Y4n8GL0QVBprs3yXyvi4Tu0COuZL9BerOw
# 9q6PNs1T1i3gVizt2ch7pYrWexfEJGJdaV0jxvtvR8+K1HcqnDIA/bsZRHBnG5g1Z36rIhb+6eJ0
# A9LSuQ2EaXHA/DOyBX1i7MQMH4LlSP5MSHlOkKr4bVixYFEJgOw1nYJQRuRoDFnE6WFC9mA0KHAw
# BXSbfpd7TbzcXGV3LHdjjdeb8dbpYlSd1iSvYFAurv4mJm9/Gi8OFgSuzPllGYSTsbnl5Ye1Rd0e
# Rxz9GkiQVZwigi++I8s+REBR8a8Oo4EjdkQQzaX9OZZ9ZrdoFvMrtTAHydim78FtvqUbx9K2O4yo
# X7xbpaLa61dCmRXIgetwVJEY30+VjTETeZdXXOOCVa65fJBc8wdrugSwIjcP3v2ZkziOCoB7Jqj0
# taxZzg4TyeGO0J5jn3lsUwLunj46KLqcKKu8/CC/HF6wtOY5EzGRKarUxYpWENgKCm4VIKqkHleM
# nCdC5U0n63URMDkWTuNmnX4MRf96EKh+SjZpOT5RbFjEGXa8cDyNT7oH14tRyI8Kk7lX/1CM+Pyd
# aup9MO71Sj+vzftVWuzl5sNO+8xLrIz7wHTWO8CUPD7DIfAgid9orpy3z/iCOmlfeDE6JQDNFNpo
# ERzWb+jmC4gNdzbv69RrEXeLA7SEHRXiaH57msTEZTC5PNYs6Jd/xMeKemS0ft3Ea/VNkiIoDzAm
# AsealfjaP77OTwXSUnxKONkP7+Erl3f8Uu598gRTYbZdPHSOrN2yFuc5D6qQHiFHZeaLr6sCT3a8
# 5O/VmgrHc4AhPonrZLivQkY8SqhRPnRV+FJlUMa0O2zo19Zs/TWBDOX7Jb7cLPBRHOoskEUZAp8v
# uGqbawaKHyi/04gcwrMIxjLzGw3gnSdgP/84bwDBvCfd3CosG/8NQe9vOiozNK4iLc24ElPB17jj
# 0pvWQ1R2OrZ7n4eqreIaU8Nl8zk/e0wAqHfro8pIoKbuQIcaVg9QgnuPd4wys0Oqsu7k2sik9349
# YRqRr4pM+ttlryKRk4Mdq45fCKBrMWStmBskbkLYLx7bLObkK3fz7b/UhOeG7jUihvCAeb3bKwo6
# zzPV4ymGsHSN2NESYflMv4nGpU0FyIw90SnrVrPW1LdvSBs5CJ8RtYsX7/3GaGFJzjrAvSAgkUXj
# vnKd4R22YcDNQNCtolOIVCYsVrSboqfcfmWgegzxLa5vfxk/foU1CE2fP/XFFC+B+991tWnq9wAr
# lMoN1fHX43XLZTebdTSb6pIJ/4UTK3lEOYgc0njJstaE7zQZ5zS144k7j9RVh+Xz32Dve3azBWGz
# GnmEAByOCL/QcWIszDW066p9mCYAz2K8DhhIrQm33xX9EspLkm/lkWZZ8NOSUSmHfWCe5WWDMx5N
# SF3hU6JxEnL9w05J0kcpdZ2/YaE8z4VMo78tuIzCF3BiQY/KuUJD+JIrkzrM6Jyek9DIVbShWTId
# 0Rp6Vlh27Oqmla/lEna35ZX7ZKclNWcrsfLL8mBSuaFgALAyqT1EYJ2Cgg5DNiv7bkObS14as25H
# Ik69QpB/aQZMmBqekTJ86OV8xsvB+CNglNnIcxxItGk7QAFgV8RfpDeHoEDi0nP6MZ8Z5sVKEn+s
# 8wu9Mu+pDbGJzMWWHwyTmnQLDB7rmoqi6mcnfW3GGTBL9xkgdgdQXk9XgAKz2RSaN7FFpx2A20Fi
# X5wVIf9ylFD2OC22G37r9wHljO8KnheuJQpvRlIL3oIpJPA4Sxw0j6mjiheBHxfUp6h3eFPmI2yj
# ycSl2HfmMTzrTKGdBj21UXScSH38w3godjZnHsbQ3HqLZLRY1jEvzQRqCLrfPQA3Boc7hE6mn2K/
# Xme6viOBzAzM47kf0PDP1r8/ADdwv8KNxZ476xRYss83Mt31594Yt6Sizg4qs568hdJZ2pp6+pp/
# /0EstwbMHnQVPA/omncUJSGaceK8ITx9qTXrnDDBxnSq4If8DbUEZYO5nbzDM4v/xytvc6jTCufE
# lh9Geu3UEIK2sJEMf1xBjwh4RwPXcmgyP6BAY6tztorLmhCoJVc/XD5TUB2OisB9W7IsUEGA9gow
# J4vKqq+Ip1kUB7RngXeyOYB98X3vqFzAiqa4ZljCy2Pq/QWOzp+yzozVG0kQTDSVgPXsODaaR8BB
# 337lrg0RiCU8unsQ2b9zGDCJ08agdwowJKJcevOhLcRKYUoiWhYvCcvTcTWdrhrqY7ntK9FohE6X
# PyhNaQnt2QUaejUy2QBU5pkUATWOEM8N3tIw/6jtyAI18ZKHzsd8+ddv5CtOJ4mPU5mAm8LXxdoE
# iBm8CFnkF37lqW2AKhbRgyq5G2ryHeT17mhQvCKej3A1aQ1YDYYHPZffhYEbfPtuTjL+KybdlMQk
# gLI4BSaYHaVonHllkwwYJp+oXGXFuOX8hT9lc+nnviYN2HY9XWSewQ2lwLkmIb0zAVUSvyjAHsxL
# eBUCOtHvGoEZyCNY5cfMu2oZoMkiqQPlbM/+ELHxzoloSMjHHfvH2xT9vl5qVnjj5OXcW2DttOs2
# g+uV5KnOCc0IABSMZRF4fMHtiv76IuhvzQB0Ej3qzxQNOLbq7kxNJCtbRRD4XjUsM8mt82hwmL0q
# LrZC5db/+gTAD9B9RvEBQolHwEYVDzoqwCEvvIA6LbLf4HWKQS8GPS+4fHCvjRdFRuQsrv+GNDUa
# MFUsieBl7FUKIIH3UmE0DmnWSCru6gMx/lnJw2iHhX4FlYMuSOB2S4YUAOylkxQXO3YT3GvfLlkV
# 9+AsF0vQ5YlBj4xrLPW2oG0ioveW7bU9YjLMI+Cg4jLsFeALMmL0cspBoR4DZgWYMKH+dO01ghdl
# krgOJ3W0QG9hqjtvc23hfEEiAZUaKb4Jpbm0W1pNtatBEQdo67VAmXd7xZ0fexpmtIJBxnUJWkr7
# Xk/UC5Ee33WhJC5kU4rGIHMnDUQDTtil9OG5BtCnjgNssGxhw+Uzoe79ZoBoFu6uphwOQ03O0G1/
# lQ7vGRFubk62pzsVpFwIGGv25yb62gFWFon+1NywNNNIWP4Ltks/8aPQNBImd+upli2si6YLGJWx
# 4sOAwU45DBAC7DsDEFT/4ixfEE8Pm084yOoZ/JqUqCVUr8PELIQYEiKpg3NkNfnvbn9zfDVR1H9+
# yeWY6N54cma1M39WNEjpHjro2354DFJkR324dRfqC/MDKJdutX1OEoSTdgP2VVFuHeUWZS9SKAmR
# Aqvn6WEg24Ms2g0wZFGV8vL4MKHJtWPP2OgXASpCJDaFsGRUL0+5ItYkLN9fV2rYuaRnJSpSet7j
# WGUa/iAUQe5qelyAVV8DTMsNsP4lzhHi8c9hhcOvdVjyKyW5vnHDjTcCRZ6e34ixALuvGoKRwgnx
# 1QfDUOQkYxYVmCyys7h1paLWNlI+mlzbc4qino/MUlPCnJfDsvukC6cVQdDtXMAhFRZy88HaPrA6
# fMdFsBhItjGSPn87n7DTcCMNjEOGoOzebpmyDSzjbTaQJwPMmw3QPD0U3zAhC2IZ1oo1IXigbh1D
# f9ixFT8r7X1JDTCl6qmA3b62DFcEnzOK3FU+C3og5e+TtSQCEVXLsDWgAuNRTyMe6DrvhGthRUz/
# ro6DvJAEKx/fOkK9GyDGb1PsJDvaa7OZ5F5IWjIWtBCoaGjd/IVtA3pOwDThwYgjnatlfL9BYvKP
# TTJWchmF/dLXPJSK0jyVtwhomhkim1c4aMDE3gM8PT+RXoccd8IWJIQcB275Qr2xTYQFuBgPaAJ0
# FzEhp0TMv04goPJJXDI1KAVdh0rG+DZyK6VGu4Wt1ZeLQCR0uOMm0vLiD/GrIAwt0RKkPbqgV+w6
# rign2q9dJcJZCXE/mmcdJqLgkHmdASJSaNNAzrMwIXJCcRipCGxcJ9HBFGF9szi20T5cmNucIu2F
# eK4cdfV6VblFI2kgzgaawGZ4FePOBO9MxjyK4En7BWfrmzfDw6UExWXu49xQFkjE7dOu7ZJwu6+w
# rYiuE9axeWdaQwR0KusQn3i/Ak/s/6fohPM1d3xYugqjB20RkNmOiXol/o+0dF1I2gOcYMlApkkY
# ysK2KWKYAbjnqiWnwufgV/beP424WpZizH6mDGpo//qOAZz5VBD7O5/CaJdLq+272YZOlk6WYFnJ
# ZgmerW8eAXuAQ/e+yKlDDGk42+rzvqN5/5fFI5iCx+lbNcPUseiYpoxsZL/qf3v4fy4ewQpcSndP
# IMwei15vSopADv0vaTwCOhymCxHY4TC4Y8l4ZI/G/wcB1oYFa9e1iYCpqfF1NWUq/ZuAxzYFI8Mt
# eF8j+TWCLwQi/qce3jszfz7eQQtREJxAhnv8V1P+B8HGv9+BrSOuKEGX/2D79x0Ykg37953/A3i6
# 8G0uHQAA
# ----- SOUND END -----
