
# Create a Device Certificate for a specific device
openssl genrsa -out ./certs/deviceCertOne.key 2048

wait

# Create a CSR for the device
openssl req -new \
-key ./certs/deviceCertOne.key \
-out ./certs/deviceCertOne.csr \
-subj "/C=US/ST=WA/L=Seattle/O=Witekio/OU=Cloud/CN=device123"

wait

# Sign the CSR with the root CA
openssl x509 -req \
-in ./certs/deviceCertOne.csr \
-CA ./certs/rootCA.pem \
-CAkey ./certs/rootCA.key \
-CAcreateserial \
-out ./certs/deviceCertOne.crt \
-days 365 \
-sha256

# Create a certificate chain w/ the device cert and CA cert
cat ./certs/deviceCertOne.crt ./certs/rootCA.pem > ./certs/deviceCertAndCACert.crt

# Set the lowercase fingerprint with no colons as an environment variable for the device ID
export fingerprint="$(openssl x509 -in ./certs/deviceCertAndCACert.crt -noout -sha256 -fingerprint)"
export device_id=$(echo $fingerprint | sed 's/.*Fingerprint=\([^ ]*\).*/\1/' | sed 's/[:]//g' | sed -e 's/\(.*\)/\L\1/')

# Get Amazon public certificate to establish mutual TLS
wget https://www.amazontrust.com/repository/AmazonRootCA1.pem --output-document=./certs/root.cert

# Send first MQTT connection attempt to register the new certitificate (this will fail)
mosquitto_pub --cafile ./certs/root.cert \
--cert ./certs/deviceCertAndCACert.crt \
--key ./certs/deviceCertOne.key \
-h a1btsyszhken4p-ats.iot.us-east-1.amazonaws.com \
-p 8883 \
-q 1 \
--tls-version tlsv1.2 \
--topic /$device_id/stuff \
--id $device_id \
--message 'hello' \
--debug

wait

# Sleep for the provisioning process to finish

sleep 3

# This attempt should succeed
mosquitto_pub --cafile ./certs/root.cert \
--cert ./certs/deviceCertAndCACert.crt \
--key ./certs/deviceCertOne.key \
-h a1btsyszhken4p-ats.iot.us-east-1.amazonaws.com \
-p 8883 \
-q 1 \
--tls-version tlsv1.2 \
--topic /$device_id/stuff \
--id $device_id \
--message 'hello' \
--debug
