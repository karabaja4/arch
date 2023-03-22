#!/bin/sh

_file='/opt/azuredatastudio/resources/app/out/vs/workbench/workbench.desktop.main'
_js="${_file}.js"
_css="${_file}.css"

_success() {
    printf '\033[32m%s\033[0m\n' "${1} was patched successfully"
}

_fail() {
    printf '\033[31m%s\033[0m\n' "${1} was not changed"
}

_sum1="$(md5sum "${_js}")"
sed -i 's/this._connectionStore.saveProfile(\$,void 0,j);/this._connectionStore.saveProfile(\$,true,j);/g' "${_js}"
_sum2="$(md5sum "${_js}")"

if [ "${_sum1}" != "${_sum2}" ]
then
    _success "${_js}"
else
    _fail "${_js}"
fi

printf '\n%s\n%s' '.monaco-workbench > .notifications-toasts.visible { display:none; }' '.notifications-toasts { display:none; }' >> "${_css}"
