#!/bin/bash
set -euo pipefail

curl -v -d "{\"to\":\"karabaja4@hpeprint.com\",\"subject\":\"hpeprint\",\"body\":\"print\",\"attachment\":{\"fileName\":\"file.pdf\",\"bytesBase64\":\"$(cat $1 | base64)\",\"mimeType\":\"application/pdf\"}}" -H "Content-Type: application/json" -H "Authorization: Bearer $(cat /home/igor/arch/secret.json | jq -r '.emailToken')" -X POST https://mail.aerium.hr/send
