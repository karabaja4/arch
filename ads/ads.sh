#!/bin/sh
set -eu

_file='/opt/azuredatastudio/resources/app/out/vs/workbench/workbench.desktop.main'
_js="${_file}.js"
_css="${_file}.css"

_success() {
    printf '%s \033[32m%s\033[0m %s %s\n' '[' 'OK' ']' "${1} was patched successfully."
}

_fail() {
    printf '%s \033[31m%s\033[0m %s %s\n' '[' 'ERROR' ']' "${1} was not changed."
}

# set 2nd parameter of saveProfile forceWritePlaintextPassword to true
_s1='this\._connectionStore\.saveProfile\((.{1,3}),void 0,(.{1,3})\)'
_s2='this._connectionStore.saveProfile(\1,true,\2)'

# do not show "installation appears to be corrupt" prompt
_s3='\(.{1,3}\.dontShowPrompt\&\&.{1,3}\.commit===this\.productService.commit\)'
_s4='(true)'

_tmp="/tmp/$(basename "${_js}")"

cp -v "${_js}" "${_tmp}"
sed -i -E "s/${_s1}/${_s2}/g" "${_js}"
sed -i -E "s/${_s3}/${_s4}/g" "${_js}"

_result="$(wdiff -3 "${_tmp}" "${_js}" | grep -vx '=.*' | grep -v '^\s*$')"
if [ -n "${_result}" ]
then
    printf 'Changed:\n%s\n' "${_result}"
    _success "${_js}"
else
    _fail "${_js}"
fi

_sig='fea513f76ab8d448ea1692178208812e749710307efdae2ea5f70ea5de63a453'
if ! grep -q "${_sig}" "${_css}"
then
    printf '\n%s\n%s\n%s' '.monaco-workbench > .notifications-toasts.visible { display:none; }' '.notifications-toasts { display:none; }'  "/* ${_sig} */" >> "${_css}"
    _success "${_css}"
else
    _fail "${_css}"
fi
