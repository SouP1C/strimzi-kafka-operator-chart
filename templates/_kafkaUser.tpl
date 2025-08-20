{{- define "mychart.kafkaUser" }}
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaUser
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  labels:
    strimzi.io/cluster: {{ .kafka_cluster }}
spec:
  authentication:
    type: {{ .authentication }}
  authorization:
    type: simple
    acls:
    {{- if eq .user_type "microservice" }}
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: literal
        operation: Read
        host: "*"
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: literal
        operation: Write
        host: "*"
      - resource:
          type: group
          name: {{ .namespace }}.<some_prefix>
          patternType: literal
        operation: Read
        host: "*"
    {{- else if eq .user_type "console-user" }}
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Read
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Write
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Describe
      - resource:
          type: group
          name: "console-consumer"
          patternType: prefix
        operation: Read
      - resource:
          type: group
          name: "console-consumer"
          patternType: prefix
        operation: Describe
    {{- else if eq .user_type "customer" }}
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Read
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Write
      - resource:
          type: topic
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Describe
      - resource:
          type: group
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Read
      - resource:
          type: group
          name: {{ .namespace }}.<some_prefix>
          patternType: prefix
        operation: Describe
    {{- else if eq .user_type "connect" }}
    # ACL's for topic CRUD
      - resource:
          type: topic
          name: "{{ .Values.global.connect.config.groupid }}-"
          patternType: prefix
        operation: Read
      - resource:
          type: topic
          name: "{{ .Values.global.connect.config.groupid }}-"
          patternType: prefix
        operation: Create
      - resource:
          type: topic
          name: "{{ .Values.global.connect.config.groupid }}-"
          patternType: prefix
        operation: Write
      - resource:
          type: topic
          name: "{{ .Values.global.connect.config.groupid }}-"
          patternType: prefix
        operation: DescribeConfigs
        
      - resource:
          type: group
          name: {{ .Values.global.connect.config.groupid }}
          patternType: prefix
        operation: Read
      - resource:
          type: group
          name: {{ .Values.global.connect.config.groupid }}
          patternType: prefix
        operation: Describe
    {{- else if eq .user_type "mm2" }}
      - resource:
          type: topic
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Describe
      - resource:
          type: topic
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Read
      - resource:
          type: topic
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Write
      - resource:
          type: topic
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Create
      - resource:
          type: group
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Read
      - resource:
          type: group
          name: "mirrormaker2-cluster"
          patternType: prefix
        operation: Describe
    {{- else if eq .user_type "schema-registry" }}
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: Read
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: Write
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: Create
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: Describe
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: DescribeConfigs
      - resource:
          type: topic
          name: registry-schemas
          patternType: literal
        operation: AlterConfigs

      # Group-level permissions
      - resource:
          type: group
          name: schema-registry
          patternType: literal
        operation: Read
    {{- end }}
{{- end }}