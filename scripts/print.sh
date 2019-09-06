#!/bin/bash
set -euo pipefail

curl -d "{\"to\":\"karabaja4@hpeprint.com\",\"subject\":\"hpeprint\",\"body\":\"print\",\"attachment\":{\"fileName\":\"file.pdf\",\"bytesBase64\":\"$(cat $1 | base64)\",\"mimeType\":\"application/pdf\"}}" -H "Content-Type: application/json" -X POST https://mail.aerium.hr/send
