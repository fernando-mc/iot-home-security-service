# Create a cirectory for all the certificates
mkdir certs

# Generate a root private key
openssl genrsa -out ./certs/rootCA.key 2048

wait

# Then use this keypair to generate a CA certificate (the pem file)
# In this step do *not* use the code AWS provides
openssl req -x509 -new -nodes \
-key ./certs/rootCA.key \
-sha256 -days 1024 \
-out ./certs/rootCA.pem \
-subj "/C=US/ST=WA/L=Seattle/O=Witekio/OU=Cloud/CN=$USER"

wait

# At this point, you will have two files:
# 1. The private key - rootCA.key
# 2. The the Public Key for the CA: rootCA.pem

# Now we create a new private key to do the signing
openssl genrsa -out ./certs/verificationCert.key 2048

wait

# Then we use this private key to create a CSR or content signing request to be signed by our root CA
# First, set an environment variable for your AWS Registration code:

export AWS_REGISTRATION_CODE=$(aws iot get-registration-code | jq -r .registrationCode)

wait

# Then we create the CSR using the registration code
openssl req -new \
-key ./certs/verificationCert.key \
-out ./certs/verificationCert.csr \
-subj "/C=US/ST=WA/L=Seattle/O=Witekio/OU=Cloud/CN=${AWS_REGISTRATION_CODE}"

wait

# Now we use the CSR with the rootCA to create a private key verification certificate
openssl x509 -req \
-in ./certs/verificationCert.csr \
-CA ./certs/rootCA.pem \
-CAkey ./certs/rootCA.key \
-CAcreateserial \
-out ./certs/verificationCert.crt \
-days 500 \
-sha256

wait

# Now that we have a private key and a verification certificate for the private key we can register it with AWS  
aws iot register-ca-certificate \
--allow-auto-registration \
--set-as-active \
--registration-config file://permissive-provisioning-template.json \
--ca-certificate file://./certs/rootCA.pem \
--verification-cert file://./certs/verificationCert.crt > ./certs/cert_id.txt

wait

export CERTIFICATE_ID=$(cat ./certs/cert_id.txt | jq -r .certificateId)

wait

# Activate the certificate in AWS using the ID from the previous command
aws iot update-ca-certificate \
--certificate-id $CERTIFICATE_ID \
--new-status ACTIVE

wait
