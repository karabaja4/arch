#!/bin/sh
set -u

_echo() {
    printf '%s\n' "${1}"
}

_usage() {
    _echo "usage: $(basename "${0}") [ <card_name> | l(ist) ]"
    exit 1
}

[ "${#}" -ne 1 ] && _usage

_unmute_max_all() {
    for channel in $(amixer | grep -P -B1 "^.*Capabilities:.* pvolume( .*$|$)" | grep -oP "(?<=Simple mixer control ').+(?=')")
    do
        _echo "Unmuting ${channel} to 100%"
        amixer set "${channel}" unmute > /dev/null 2>&1
        amixer set "${channel}" 100% > /dev/null 2>&1
    done
}

_write_asoundrc() {
    printf 'defaults.ctl.card %s\ndefaults.pcm.card %s\n' "${1}" "${1}" > "${HOME}/.asoundrc"
}

_switch_card() {
    _search="$(grep -iwH "^${1}$" /proc/asound/card*/id)"
    if [ -n "${_search}" ]
    then
        _index="$(_echo "${_search%:*}" | grep -oP '(?<=/proc/asound/card)[0-9]+(?=/id)')"
        _write_asoundrc "${_index}"
        _echo "Switched to card ${_search##*:} (${_index})"
    else
        _echo "Card ${1} not found, exiting."
        exit 1
    fi
}

_list() {
    _default="$(amixer info | grep -oP "(?<=Card default ').+?(?='/)")"
    cat /proc/asound/card*/id | while IFS= read -r name
    do
        if [ "${name}" = "${_default}" ]
        then
            _echo "+ ${name}"
        else
            _echo "  ${name}"
        fi
    done
    exit 1
}

_play_sound() {
    sed -n '/^# ----- SOUND START -----$/,/^# ----- SOUND END -----$/p' "$(readlink -f "${0}")" \
        | sed 's/^..//;1d;$d' \
        | base64 --decode \
        | mpg123 - \
        > /dev/null 2>&1 &
}

case "${1}" in
list|l)
    _list
    ;;
*)
    _switch_card "${1}"
    _unmute_max_all
    _play_sound
    ;;
esac

# ----- SOUND START -----
# SUQzBAAAAAAASVRDT1AAAAAcAAADMTk5OCBNaWNyb3NvZnQgQ29ycG9yYXRpb24AVFNTRQAAAA8A
# AANMYXZmNTkuMTYuMTAwAAAAAAAAAAAAAAD/83AAAAAAAAAAAAAAAAAAAAAAAABYaW5nAAAADwAA
# ADYAABzbAAcXFxwcIyMoKC4uMjc3PT1GRk1NU1NZWWBnZ25uc3N4eH9/hYWKkJCWlpuboaGlpauv
# r7W1ubm+vsLCx8fL0NDT09fX29ve3uHh5Ojo6+vt7fDw8vL19fb5+fr6/Pz+/v///wAAAABMYXZj
# NTkuMTgAAAAAAAAAAAAAAAAkAsEAAAAAAAAc2zRCDlkAAAAAAP/zEGQAAAAB/gCgAAAAAAP8AUAA
# AJML5XU5//PQRAULrXtRLsjQAB8a9q7/mKAAIJRJLRIAEAnL0cLaiAGoNMggZraOgbAzZKgYMyG9
# kCA1hQLSjTPss+30H7y/9CqkjUq+ggg6SCyQKyJfSFCCBCiSJFn/701N6Tmjt//////////5n//e
# YM7ujw7RQ/7fr9vRuAG4AJf1a2ba4f2sphFSTFJYm9pcWxnBvC4zoC4UVMrgBRAcWHYtMbSJqZMr
# pkUNqCqZfT8ijFAwLyMyOJJ6BcNDc2Lh0aA7iKkHcUIHMI8gJDj//N6aj2mmRI+LkL7VqV//////
# /Uh//qH23/5uYEmpoQuAAoHbEAFyrz//X91k19ybF+1TZ/lHnGHPEN4RauGq//+omjcl///SD4Ik
# N1kiSHcSxeSMi8XkUjb3qGo9///7f//////2E9ITUU0MAcHcCAAzb1raiMYUE1eoojcF4BOBRZZ3
# //mkgZ///qBMuD4ShqRVR0ajVjjeppptQKgIe3//////////i43BpYAI0DcB0zALSHr7jBG0aJVI
# VGg54C3IHOx2J6f1qfW7bGI2///+JEKi3BG2cmA4/iNGxCHvgYJm///7f//////4Sx1aGFSf/RxF
# RgtsfQYA9l9+rxCckKPWkmISDuD/82Bk7AllR08v7LQAEJqKnl/TOABFZIO9BqvWzpurzMlmWX3+
# m//kNFvNzegtAwRPoIF9NNN/WOeR6v///wEHdxAU4Q9QCh+OsKgB2v6uoQmGYJouuymTLg6QSyA5
# +aOpWvGaC5gvomqkvYgZXdFvrZf/koMQiJidLheTRSSTJgnVJfqGeNm///57///UYhuoCPHf5KiL
# gAJop9D/83Bk5QkNU00uUSrAEOqinlygC8QgAPpt1+PA7zU2+pYjMFakW0fnTZvtTSIoO9qX6n/9
# QtxNEGSUTLIpENNZw3V7VihRpP///+DGvKAiVcMNEJ/B5BQAtT9NlViQkPNE78vjqBByBh9NV6ka
# J8c9JP9NAP+MNX/V/4oQbyK0VHHQ60n++NQWFf//+tv//9AoQ62G6ALQJMJ+BQAl/5NGi9FKtRRB
# Dojk4uk7P2+vx8Fb///i1v/zYGT6CklHUT9QCvAQQqKifpgFxECRTuiyfqf1tUai6LX///1CYj1J
# qsIMiF7B0xAATzo9F1VCMCeNS3e9ZDAQoQFB0V27ovICIWLKkfrQF6Nr/1/+IkKg5oyBYdJbMk/7
# 43Cq////b///iWDWyf+4ABWh3jeMQAf/Oo9kjIxI4MGg1+BN5xdF2fc8/t3GeS///0xsDllQ3XXt
# 3//zYGTtCIlFUS9QCvANep6iXpAPxP5DyTPf//9v//+GSFWhDyhfgdUUAIN6usWWNE3NK7kwVxCQ
# CtgLWj6C0+ukLAXEFfWw6RhI///4+hiWdjjoe9X8lCk///+tv//+JINXl3oF0YWwHoEACf/TFdHp
# BHUkYmQ3QinAtvUv16i/r1ek////LBJv102Xa7fyGkKn///9ANsqgI6IP//zUGT5CNlFTy9UB/AN
# 2oqiXpgP4FHnEQDoevnBOg4yTEJEU7oJFoMVAHnyXq61MgLcVE/1zAe/QW6er/xqHiALtdnoLS/1
# DcHk3f/+pEvnDyayc///5w1ZQ//D1pGTB/o6hwGqCb6/GRE5rIoxugozKxLAPrAtwN0E6qni6DLq
# Zin/82Bk5wgxUVEvUAfwDRqGol6gBcQ9TqZYyhhroLdP/+QwaJMJOaGSaTvMbL/lBFv/9S01M///
# /oo+z+nBARAV8Z88F4PzZ//qSujywUKneocDkIGrT93DsoC6cFoovY3fXnVUAKLZ2MxlCu4zBoP4
# W6AHIbiFBZBEE//DuLNU1IUi4pBakmf3y8OSQv9FBVjMZcXIRAOlAYuMFRj/82BE+AltR08vUAXw
# EyqKnlygBeAUU7///////LpWX17pu6A/nz9ts8qbSABAPcYccEdmmzuu6qO3Iu3C+051NoIEUXaf
# ltloFBE7B7udz1+v/mXPqfrGxPSyPs4bWB3IpINTqBRyB3Iaw1y9/4tRqSZrZJ2QZZlpf0ij/onE
# rFMZcgguQAcBaeJIYFBaa///////xj9T4udFEgD/85BE5w65dUsuaHNyndrullzUS2xDzs1dGGNV
# wgdCKPuRoCC6TL//N1JPy6OBXfh0Rgj460+rOW79CBVaHA7Kyn/90JQDaC6pE6TrDqIibUknR/RC
# 2xsE6JRwSBislv9h4E//4BBEeGxJ9X9Sr/////f9y/tBW2n/ZkL0MDRlT3ygUVm50j06QggW0RQw
# GmAjOEeswKYzwFA4FyRdUt2dFv/1mxPIqeKSG0RFBNA//1CXUy0mtE4TBcVZf/Y+bf/WYDPmqZFR
# 9DiTZBv//85+hmHEaPqV+gIYIAO/dLABl67bte/SelrBjZbKn1GJe0xn4wNp+G+VLeEUt8/9JQOT
# tP//DAn/84Bk6Qvtd08faodqFnqumjygBeDKHos8Jq6f+LhVH3/8AeSacx/t////+35AX8xAoRb9
# Cf/oTQUIYAL+YAAL9BDk9+C7ns03MW/R8w7XfBZZGbH/6//9v//9QIlHz2OOFYl9V9sF8CETH/Lu
# /D3//5PWF62AOMABwxEAi5Rxw5BlZHgb5W2AE4V5LbS18TcPBhEFzoaqA5R7/6nJQSX0G//41C2t
# JFBaQ5BCoWXf+kiaf/rGUPTBae5/6v////3/N36pkUCJa6D/8w4gIgHd//NwZOoKPXdXPwsKHA8J
# ep4+DhQ0FebJAE0/j6asRU6oZ0LDEZ0mhRRyA64V+ua957L89wwAjTqe//9QsCmy3jnX/1K//8oz
# Bxfv9P/////7v6qAhsMfPohRMFB5PjfPQAYVO1vLOP9j9Rz0kQAXG+IqDhDLCez+tQuejqjGv9wU
# LOlAjAIG5qGL/4me3goZ//Kh4St/9B01BWLH7/T////839n6sYIB/nPBiiBjnYLeSNAGf13/82Bk
# /QrxdU8vB1MYEdqqqn6ChPS4z/10GYveZcEzkXJiCXnaUlJFN/7ZpZWTf6OUBLzlV+lS32E8mJ0q
# zhMff/0cl//QL1kFYfasX+c3/////6fuIo7HemqAgBjAPdvwB1+o4EnzqCFJeoCqTMXCfekpJGrR
# DoJ8Hpnl5FMUiQqv/UfF0MGlzUumVGmixDWvsDexClcyUtIuifj/84BE5QpxV1uPDecaE7Kqpl4O
# FDRsueUTyKH6zqB7/+ILIJJK5mVvY6e////+b/pP2OFkfRhoN/86nhghxg7/Z4Bmar4/CgSXsH2G
# 9IeANo3YlimLYIShDUHSbSZxzCt/62UmMk6V0TUxMn6KJvZVzULghxSfvA0HiR6odUN+MQQBCN/9
# QolRTnzfz2//////v2OQgIv9df2CMKDv9TIAynqWkLUaYQt62ygFmwjOG4AfOJiCkJtqhiK//cWB
# r60FL7f7BtiUG7dYgpvZm/5o//OAZP0M9XdLLgtRGBcyrp5cmhWAO41//UIlO/mb/X////+36X6y
# 4PHT//LhtQwRxA5vYoQG+slNYY1N1D+FmWmZkTZXBLw+zbZNMv/8pjw3tX11qbzobkvqTz6hNE82
# p7f6iFCl//UMLQ5X0G+v////6/o3sCDAP+nBgDDAUeyMACX0rS536wwRqqvI8xYG5MPq1J5guHbT
# CmFH/7g4N/Y3t/8XqYeqTgXA61E/5EKCf/9ATOlD+Vf1ML/////f8z8whM0//KNQwBRAJPJ8Fv/z
# cGTzChV3Vy9DLTQTGq6iXpKFhPYk2qApsxBVPuXBNgDKLY9tnW/U3zkt//ECG5ztWBgOmVf/lB4/
# /6icO5nVvs//////5rfYmF39SpBgMO+F7vL4BA/Yvrn8jnlkM0VyvmjHjAbykm/PwNf/9xAG96mX
# //gqGreCj//qPhxf/+Wf+3xz////9m/bqhgrHd6f+PuBABAwHvl4FZuM/91KvO4lOY3SvCWS9s1U
# GkefQyN//uLo//NgZPcJxXdTLwcqGBASqqJcaBUA/6v+7+kMybs9sjG67f2Ppf/qLmp+v9D////9
# v2+s4T/ruAAQUF3ZMDtwezaGEaPxrGqUW28Bg7GM5oQpWEJAfCroVEMfX/3HUJk6CajiJ1m9Rgba
# c4GyjlF+dPseDl0z9nb/IaVS5//IG1Xrb6Tf////dvpN1rTKZe+//MVC4IMCmT7RgDh3//NgRO8I
# xXdffwXnGhC6oqJcBiAwyWUPnv1BLVt5Bc2EZ5ux3IJY31tq6ff7i+N9N1Kt+r6jIqI1vpnu//Mz
# U0//OETdzJuUT3Nf//ke/+h4UCAi86+N0ANGuRs25D4FmiegT5WN45gZ5tODzUEmFR0CWdRP8mNR
# 5/c4QuddI0U3761VEPFQJVUuYoDon//yATB6//1GDUfqW+e3//NwRO0LjXdNLjMRJBEp2qZeFmIw
# ////zG+zbqYRiP+pYcxBHe/f6tgNhKSCbrGNC1zWNkIRX9amwnSI1+XxWaz8/sYSg6KlLSQ9t+f9
# BHObeoUIn6/+KwhCF//lSQtORuS8l//+jgH+qnhAUIBJTzzOgBq0aR0NJvWCOkcwEvAN3RYL+Zg9
# Bk7Zi9wFI0PmMGYUlzTTTT/7/i8UNpQgD9v/0ITn/+okjkx+Ruzv/+rhykSgl/X/83Bk7Qr5UVV/
# PkpOEjHasv4T1DSMwAwuOtJEwOVDwf+aet+43c0gp8KleQ8Sek/fyN03Vpx36A2xxxxtNP/UO/Vv
# /50l/+g++dypb5v//////+o0f/J1+wI5oF/ruIBA6uLga+cEAvpJgNU/iLk/FKfxNaftQKj//xeK
# L5hn9XLeeIANTK6BkNl3/5hIOf/qRNROpb6v////9vzF88oQN/jAMEOMD78vwoVUYv+mESfJeJRW
# i//zYETtCYTpWY80aoAQkqamXi4OULNwZdhgPxcf5W//11jd81dv/6IiW6po3/9jRm//d/7fX///
# ///V/MEqoAYgwfnZgBC+42LDWKP7ZospSN0ne56pIiTQWaGi6AmRAS/9JAMIWNOovHjilIP0T3xi
# IopOzxP3W//3MT//9Brr/8y///////1JHP/+cWGjxhc9kSs4E9vFZ85m1f/zYETlCVFTVy8F6hoO
# +qamXAYaMAqjrbn5AuKODiDI+nccCSP/mJqYAqkUs6fddm/9QiUvj8af/zhmat/+j26z3///+GH/
# qrWAOMFp4qA1n/3bSXlpiwQVzhjQCByXc2gWpbGuD2+5zCSJq//hVL0zlMNVvYt6g8BeTEs+oUI3
# 0f/mj8z/+RNp5/0//////2/c30/9y7gEYcff1//zcETlCe13Ty4HDRgQWdqZugYaMBh0lNjlxg1R
# QFrfgSunEQcGR98S4oP/5PPgwApZl2NXQr9j3rH4OFT2yYUf/6ZfN2//Sa30fq///////5eJ/xUU
# BCAYF8/NAfSDK/Ah0LS0CKc9KRFn6YAuwfd8U+v/qQNSZGUW66CTJP9T/H4T8fatp0l1//UR5BjH
# 9VH2///9ZT+tIV2HDH2oYY3mUQDa8COQM/cJjSGroVj+j//SEW////NgRPUJ1XlPLj4qYBFapp28
# A9ow+j83Fuv7t//MU//8udLrNP///81/mSMMF37cAurUvmUW2uEiFRX1hHinBLwrfcnCXb/8jBDK
# S1IkRR/3+ShOHXVZRwhf/7FQ0b8WEgXlnS////rO/yABVeHF3vmQZKmPnZJEFozQ2Gs5cJckA4W2
# Tkofb/2REOCqfu1f6i31F0L5+3/+gWjw//NgROgIbL1RPinwJgzp2qW8Atow//mTylRzJf//+Sd+
# ojUAjCh63qEMG45Z4rzyGZgDjTx3iPhC6EO/y8l/+5ECV90me3ul8QgtEH9NL/9RmF+C+t/+vU/n
# +3///wD/UDQKUKfHC3+kDA+fO6IyIcSE1qrgAtx80VakBjD0+tnQP//uMw8fff+r4zEu3yel//pn
# v/5nL1syf/////NQRPgH/L9OjgHwGA+hsqJcA9oou/pDKgEsOOH9vsQwbyxjsKpolwaW/Eu4mcEC
# RPZyYz//SGMMui9M9e3pt8QxJs/mP/9ToDAv/9aJrWpHOne7///2f1ioY8AX/+5B9agaEKw+j1RE
# GDfegYn0BCDf/YGSW2htE+reorDH8QBn///zYGTmB9ztTt4B7RgPYbKm/gvaMKGE5C/5d5HObP//
# /J/7KqHmcMJndAwX4IcZ9NimEkacGyHRF+YTKuioEBvzG//kIbeY1v/6jr/Ob/9DiAVn/+pE9Euc
# ////hvLgQ8QDAm29AoDwKl/iOTVxFDWuVE1xVEg30v/1pEQb/Uh/3+ZG/6L//zpwlX/JXW////7q
# kdQI1fU+oCAS///zUETwB/TrUy4B7RgN6XqmXGgU5FBgYuDI5XO/M5CF2MAYNPmjSzQCO1+ixuan
# /5g96IjfVW/BL8T//5xhD9dNH///+f0gBUcYLfxQMCPj1iGN4xxTeYqCDB0Dv5jL/+UD/1J0b9k+
# eLC/EZ//7Hkn5b+d/////LIQvDjifXrMPnj/82Bk5QdM2VMuBeoYDbF+rn4C2jAdjl4I31DQnxYt
# +kN4uz0JrT8x41L//ngYGF0Hhupt/Mb4+U/Mf/+OjQiz6ezt///8M6vWATRRhP56EHV0TGChS1hy
# jE/uSnhQhZ/Hxb/5sYAeosejwoluilvUXBD+rf/oXE8Kdv/qKp0fE////+Fv6zUBjPLCj3UMP0Q5
# 5ZjsG5YmgSE06Sz/81Bk+gbsvVU+BecaDJF6pl4DVCwoC7+d//uGAbOn6nBfzN//ipHfFux////8
# J/0jERc4P7+hh8+DcZiqagVwGNzyQZgiAv/Ep//pFwWPsad+30CgX8SP/8wXkf/8e83Q3hpf9CoR
# KmiBu2Yn1JhJTdOPceCxNhI/OCog/0Po4RB3//NQZP0HnL1RLgXnGg+Bsp5cA9Qs2//5b+Y3/9Dl
# //USc07Ql////3oUCKFwwe99DBvqGK3HTygn4JLE9HcHAi/IW/+jiMFnzjr/t9Aojvz//6iUOJ//
# Jv0Lnf///1UVAFtzKQOYJhGhrk1mWAb4lpcf5oUR4b/5//6IBMj6Gf9vjf/zUETvBgy9Uy40BaAN
# MqamXFAF5Mz///nKd/+g9BGXAk84wl/2YgFhuRs6CAE03OM+fzeVeIw5f/k//6R8HPn/6N6iKHG9
# RIb/9TjTv/4hH3zzl+3///////LuS74oACkyMQOUNJYgYOm+CzJxX6kS8KL/R//rElSb/+pvWYo/
# +WD/81BE9gYI608tNAeADYnWpvxT1GQP4cfid////9IrVuHDH1nYfcAcyUxUTdCYQ0w6nPX+VIVT
# J/1njV//oghBn/+zeVCEM/jv/9TCjf/qf+pz/X///////UUnUfkqA/qQIgr/WIc1pDiSsFK3SOiH
# EQ/0v/6x8NP//+z/ynEfrAIg//NQRPwFoNlJHAHnGg+6pqZeA9Q0xog00AgH6wrzXEpEVKIWDXQY
# 1JYVv3f/+SJBb/+7eoei/3//zRRo3/1/6DYUfIesDwboE14HSO3UHCJcTgP/UJoWf1//RxWFH+/F
# Oz9Rr8vyQqDOGEHvoQemgmGyN61BMh4HRHB3SqRKRWM42//zUET9BXyNRxwB7RYP6qaiXAvONPmn
# /+I4v+5P0DYBn45//khsLy3/0JuJUf/////DagRhDV+oKIhYgaOS35otvq/2YXBa3/iv/yH/////
# 9FEGEG4ANvQIA3zICkEVWJOCMmQV4Tp5oXxkGYgo2fks3/93//1ofYzb6bf/0ScY//z/80BE/gQ4
# v0rcNALADMqqol5oBeTn6kXwo9s83QzAwIZH6kyYiHlf4MBb/oJYRv/6j3/qtT41o442DBvXEMgz
# gtIL5gMAGpq1LUUAyN8x//WoehHb//X8iF7/Agn8ndb////U7+gEYf/zQET8BAxhQrgBihQOQbKi
# XGgPQAv1Eg2J2emAJhvjULb9WCoFv/////////04MZa0cfbHl+gOYSClB2HcVgF4Aw0rsWpDyAXX
# +c//phXCRbl/CgF/O//8hw7+sKKaokoDC4UCiACx//NARPUDxGFAxDQIgA4ipqZ+aAvk92a4/Ae6
# XyILf/yiP/I2sRuihA++DBvUsKM1x/IyQg4No3ZSZqiLMFz9f/9RJjL+/xAn9//5Qfv/+Nd8Sf//
# /1uR+moBisVBBiCFT8lQGOG8/x//80BE8QLgX0bYKApyDIF+qlxoBYCFN/q//zjv/I/+sKMOQ0QU
# Vyr+RXUfDlOyPYmIaE3zaJDRFZvmH/9hnJL//X+bm/6X//dL//bbnU4KoP8Tw/WF1dx2gSw1+4v/
# 4b///6I7KUGIJf/zMET7A2xfPsA0B3IMgX6iWGgLQG+kEEL64gpasPgI6q7FIzDoFVV9Jv/5FLG/
# //zE9/MBH//VjZ9RItUKUgMbq4AtEmACqfMA9/8iAP/zQETmAqwxTSwBLRANObaqfGgPQIUApuEj
# 3b+eXw8GRKBMF97QRB1/UZt/8jcKQAmnt8Id1/xE/85rACoBYgJjx/akBPH/gobsGRZCGo2b1BWK
# UiCfi1MhHgkqPTUDwPT9B//5EKX///NARO4DVF1JLADtEgtJ1ppYC9owww36//4IUv//+FENOICI
# cOvGgT8Fl3/+gL9hiAewBYYIWLz+qBTeygxDJ/Of/3Jz///+gt+Ufl0GIgI1QQcSfzwx/9APkxif
# kXdZxCJwTSACq3f/8zBE+QKYXT6wNAJyCxnWkbhoC4CBoGh/n//7k3/q/+U/+B0RELxHagz+wIgV
# VAK5IXOHk6mmQLx/1nxE/o//53////+d4t/////5ZQL/8zBE8AH8Mz7AAWoUChEWqxhQBUADApxu
# T8QTAUbYACMCyGtDepRxwmQJL6iwAtP/b///4lZ///////1qBMDFz/KHAOphHgkWKQhzvRH/8zBE
# 8AGMMT7AAawYCqHWjjhoBUBFvnDb9f/+daoT5WrpAYRKq24Ch6SIN/y4If+t3///////////TQQi
# AlbHtQDfg6OqR8r8NUxBTEH/8yBE8gGQMz5wAKwYB9C6kbAC2ihNRTMuMTAwVVVVVVVVVVVVVVVV
# VVVVVVVVVVVVVVVV//MwROUBfDNCwAAnEAd4vo2QA9QkVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV//MgRPQBFDE8YABHEAf4voVwA9okVVVV
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/zMETqAQAxQsAARhgIGGaGMAPOKFVVVVVVVVVV
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVf/zEET6AMQx
# RHAAJiYEyL6OIAPaJFVVVVVV//MgROUAgAFAUAAAAAYoYnlgAs4oVVVVVVVVVVVVVVVVVVVVVVVV
# VVVVVVVVVVVVVVVVVf/zIETnAAAB/gAAAAACmGKBgAFSMFVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
# VVVVVVVVVVX/8xBE+wAAAf4AAAAAAPgChCAAAABVVVVVVf/zEET6AAAB/gAAAAAAAAP8AAAAAFVV
# VVVV
# --- SOUND END ---

# sound encoded with:
# ffmpeg -i notify.wav -acodec libmp3lame -qscale:a 9 notify.mp3