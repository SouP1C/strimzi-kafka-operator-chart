  ____              ____  _  ____ 
 / ___|  ___  _   _|  _ \(_)/ ___|
 \___ \ / _ \| | | | |_) | | |    
  ___) | (_) | |_| |  __/| | |___ 
 |____/ \___/ \__,_|_|   |_|\____|
                                  
# Kafka Helm Chart

This Helm chart provides a complete Kafka solution designed for flexible deployment, either as a standalone cluster or environment-specific instance.

---

## ✨ Overview

This chart is designed to:
- Deploy a full Kafka infrastructure with one command
- Operate independently of `<some_product_name>`
- Be easily customized via `values.yaml`

Once installed, a ready-to-use Kafka solution will be available for your entire Kubernetes cluster.

### 📁 Alternative Deployment
You may also customize the deployment by changing the naming convention to fit specific flavors. For example:
- Deploy with name `qa-Kafka-cluster` to provide a Kafka solution exclusive to QA environments.

---

## 🛠️ Chart Components

The deployed Kafka solution includes:
- **2 Kafka clusters**: primary & secondary
- **2 Kafka Connect clusters**: primary & secondary
- **1 Kafka MirrorMaker2 (MM2)**
- **1 Schema Registry**
- **Templated Kafka Topics**: `_kafkaTopic.tpl` + `kafkaTopic.yaml`
- **Templated Kafka Users**: `_kafkaUser.tpl` + `kafkaUser.yaml`

---

## ⚙️ Configurable Values

Edit `values.yaml` to configure the following:

### `global.image.pullSecrets`
- Set to `<some_pull_secret>`
- Defined in `templates/<some_pull_secret>.yaml`
- Used in:
  - `kafka-job.yaml`
  - `primary-kafka-connect.yaml`
  - `secondary-kafka-connect.yaml`

### `global.tolerations` & `global.affinity`
- Applied to:
  - `kafka-job.yaml`
  - `primary-kafka.yaml`
  - `secondary-kafka.yaml`

### `global.schema_registry`
- Contains Schema Registry config
- Generally unchanged unless you need a different naming convention

### `global.kafka`
- Kafka cluster configuration
- You may change:
  - Kafka cluster names
  - KafkaUser references
  - Ensure that `internalBootstrapServers` matches the new cluster name

### `global.connect`
- Customize Kafka Connect settings:
  - Base image (custom image includes artifacts from `https://<some_site>.com`)
  - `build.output.image` and `build.output.pushSecret`
  - `groupid` (used in Kafka Connect configuration)
  - `plugins.artifacts`: list of JARs included in the custom image

### `usedNamespaces`
- List of namespaces where image pull secrets will be created

### `kafkaUsers`
Create Kafka users with:
- `name`: Name of KafkaUser
- `kafka_cluster`: Kafka cluster it connects to
- `authentication`: Method (e.g., `tls`)
- `namespace`: Kafka cluster namespace
- `user_type`: Permissions (`microservice`, `customer`, `connect`, `MM2`, `schema-registry`)

### `kafkaTopics`
Define Kafka topics:
- `name`: Topic name
- `kafka_cluster`: Kafka cluster name
- `kafka_namespace`: Kafka cluster namespace
- `client_namespace`: Used as ENV_ID prefix
- `tenantId`: Used as naming prefix for topic
- `type`: `changelog`, `repartition`, `shared`, `external`, or `internal`

---

## ✨ Bonus Script: `client-properties-generator.sh`

This chart includes a helper script:

```bash
client-properties-generator.sh
```

This will:
- Generate a folder with:
  - `.crt` + `.key`
  - `client.properties` (for use with `kafka-console-consumer.sh`)
  - Bootstrap certificate chain

At the end, it will echo guidelines to help you connect to the Kafka bootstrap endpoint.

---

## 📊 Installation

To install:
```bash
helm install <release-name> <path_to_chart>
```

---

## ⚠️ Technical Note

Due to the inability to securely inject `<some_site>` credentials into Kafka Connect pods, a custom base image is built to include the necessary JAR:

**Dockerfile:**
```Dockerfile
FROM quay.io/strimzi/kafka:0.45.0-kafka-3.8.0
USER root
COPY <some_jar>.jar /opt/kafka/plugins/my-kafka-tojdbc-connector1/
USER 1001
```

This ensures the artifact is available without requiring runtime downloads.

---

> For questions or contributions, please open an issue or submit a PR. Happy charting! 🚀
