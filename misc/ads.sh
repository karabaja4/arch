#!/bin/sh

_file='/opt/azuredatastudio/resources/app/out/vs/workbench/workbench.desktop.main'
_js="${_file}.js"
_css="${_file}.css"

_success() {
    printf '%s \033[32m%s\033[0m %s %s\n' '[' 'OK' ']' "${1} was patched successfully."
}

_fail() {
    printf '%s \033[31m%s\033[0m %s %s\n' '[' 'ERROR' ']' "${1} was not changed."
}

_s1='this\._connectionStore\.saveProfile\((.{1,2}),void 0,(.{1,2})\)'
_s2='this\._connectionStore\.saveProfile\(\1,true,\2\)'

_tmp="/tmp/$(basename "${_js}")"

cp -v "${_js}" "${_tmp}"
perl -p -i -e "s/${_s1}/${_s2}/g" "${_js}"

_result="$(wdiff -3 "${_tmp}" "${_js}" | grep -vx '=.*' | grep -v '^\s*$')"
if [ -n "${_result}" ]
then
    printf 'Changed:%s\n' "${_result}"
    _success "${_js}"
else
    _fail "${_js}"
fi

_sig='patched by karabaja4'
if ! grep -q "${_sig}" "${_css}"
then
    printf '\n%s\n%s\n%s' '.monaco-workbench > .notifications-toasts.visible { display:none; }' '.notifications-toasts { display:none; }'  "/* ${_sig} */" >> "${_css}"
    _success "${_css}"
else
    _fail "${_css}"
fi