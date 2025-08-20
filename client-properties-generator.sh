#!/bin/bash
#   ____              ____  _  ____ 
#  / ___|  ___  _   _|  _ \(_)/ ___|
#  \___ \ / _ \| | | | |_) | | |    
#   ___) | (_) | |_| |  __/| | |___ 
#  |____/ \___/ \__,_|_|   |_|\____|
if [[ $# -lt 4 ]]; then
  echo "Usage: $0 <customer-user> <kafka-cluster> <namespace> <bootstrap>"
  exit 1
fi

customer_user="$1"
kafka_cluster="$2"
namespace="$3"
bootstrap="$4"

# Create directory named after the secret with '-client' suffix
output_dir="${customer_user}-client"
mkdir -p "$output_dir"

kubectl get secret "$customer_user" -n "$namespace" -o jsonpath='{.data.user\.crt}' | base64 -d > "$output_dir/user.crt"
kubectl get secret "$customer_user" -n "$namespace" -o jsonpath='{.data.user\.key}' | base64 -d > "$output_dir/user.key"

# Create keystore
openssl pkcs12 -export   -in "$output_dir/user.crt"   -inkey "$output_dir/user.key"   -out "$output_dir/user.p12"   -name kafka-user   -password pass:changeit

# Fetch truststore
kubectl get secret "$kafka_cluster-cluster-ca-cert" -n "$namespace" -o jsonpath='{.data.ca\.p12}' | base64 -d > "$output_dir/ca.p12"
kubectl get secret "$kafka_cluster-cluster-ca-cert" -n "$namespace" -o jsonpath='{.data.ca\.password}' | base64 -d > "$output_dir/ca.password"

# Read the password
CA_PASS=$(cat "$output_dir/ca.password")

# Fetch the certificates from the bootstrap
openssl s_client -connect "$bootstrap" -showcerts </dev/null > "$output_dir/full-chain.crt" 2>/dev/null

# Import the certificate chain to the keystore
keytool -importcert -alias letsencrypt -file "$output_dir/full-chain.crt" -keystore "$output_dir/ca.p12" -storetype PKCS12 -storepass "${CA_PASS}" -noprompt

# Generate client.properties
PROPS="$output_dir/client.properties"
echo "Generating client.properties"
cat > "$PROPS" <<EOF
security.protocol=SSL

ssl.truststore.location=./ca.p12
ssl.truststore.password=$CA_PASS
ssl.truststore.type=PKCS12

ssl.keystore.location=./user.p12
ssl.keystore.password=changeit
ssl.keystore.type=PKCS12
EOF

export KAFKA_HEAP_OPTS="-Xmx2G -Xms512M"
echo ""
echo "Done generating the folder" $output_dir
echo "to test connectivity using the generated files,"
echo "Please use the following command:"
echo "Producer:"
echo "kafka_client/bin/kafka-console-producer.sh --producer.config client.properties --topic <some_topic> --bootstrap-server <host_from_kafka_ingress>:<port default: 443> --property \"parse.key=true\" --property \"key.separator=:\""
echo "Consumer:"
echo "/kafka_client/bin/kafka-console-consumer.sh --consumer.config client.properties --topic <some_topic> --bootstrap-server <host_from_kafka_ingress>:<port default: 443> --from-beginning"
echo "--------------------------------------------"
echo "Important! If you see this error"
echo "java.lang.OutOfMemoryError: Java heap space"
echo "Ensure to run this command:"
echo "export KAFKA_HEAP_OPTS="-Xmx2G -Xms512M""
echo "--------------------------------------------"
