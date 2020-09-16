#!/bin/bash

export fingerprint="$(openssl x509 -in deviceCertAndCACert.crt -noout -sha256 -fingerprint)"

wait 


export device_id=$(echo $fingerprint | sed 's/.*Fingerprint=\([^ ]*\).*/\1/' | sed 's/[:]//g' | sed -e 's/\(.*\)/\L\1/')

wait

mosquitto_pub --cafile root.cert \
--cert deviceCertAndCACert.crt \
--key deviceCertOne.key \
-h a1btsyszhken4p-ats.iot.us-east-1.amazonaws.com \
-p 8883 \
-q 1 \
--tls-version tlsv1.2 \
--topic alarms/$device_id \
--id $device_id \
--message '{"message": "motion detected"}' \
--debug
