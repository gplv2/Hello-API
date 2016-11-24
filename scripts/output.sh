#!/usr/bin/env bash

if [ -z "${1}" ]; then
    printf "Can't be called without arguments"
    exit 1;
fi

APP_URL=$1

# get reachable ip from bridge
BRIDGED_IP=$(ifconfig | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }' | grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)')


echo "" ; echo "Vagrant Box shell provisioned!" ; echo ""

if [ -z "$BRIDGED_IP" ]; then
   echo "Cannot find a suitable private ip to connect to the app" ; echo ""
else
   echo "Possible additions to your local /etc/hosts or equivalent file below" ; 
   echo "Depending if you are using NAT/Bridged interface(s), choose 1 if multiple choice:" ; echo ""

   for ip in $BRIDGED_IP; do 
     # echo $ip
      cat <<EOF
${ip} ${APP_URL}
${ip} api.${APP_URL}
${ip} admin.${APP_URL}
EOF

   echo ""
   done
   echo "When that is done, visit : http://admin.${APP_URL}/ ,  http://api.${APP_URL}/  and http://${APP_URL}/"
   echo ""
fi

