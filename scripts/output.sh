#!/usr/bin/env bash

if [ -z "${1}" ]; then
    printf "Can't be called without arguments"
    exit 1;
fi

APP_URL=$1

# get reachable ip from bridge
BRIDGED_IP=$(ifconfig | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }' | grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)' | grep -v 10.0.2.15)

echo "" ; echo "Vagrant Box shell provisioned!" ; echo ""

if [ -z "$BRIDGED_IP" ]; then
   echo "Cannot find a suitable private ip to connect to the app" ; echo ""
else
   echo "Add this to your local /etc/hosts or equivalent file\n" ; echo ""

   cat <<EOF
${BRIDGED_IP} ${APP_URL}
${BRIDGED_IP} api.${APP_URL}
${BRIDGED_IP} admin.${APP_URL}
EOF

echo ""

fi

