{{- define "mychart.kafkaTopic" }}
{{- $ctx := . }}
{{- $type := $ctx.type | default "internal" }}
{{- $namespace := $ctx.kafka_namespace }}
{{- $client_namespace := $ctx.client_namespace }}
{{- $tenantId := $ctx.tenantId | default "default" }}
{{- $name := "" }}
{{- if or (eq $type "changelog") (eq $type "repartition") }}
  {{- $name = printf "%s.%s.%s.%s" $client_namespace $tenantId $ctx.name $type }}
{{- else if eq $type "shared" }}
  {{- $name = printf "%s.SHARED.%s" $client_namespace $ctx.name }}
{{- else if eq $type "external" }}
  {{- $name = printf "%s.%s.%s" $client_namespace $tenantId $ctx.name }}
{{- else if eq $type "internal" }}
  {{- $name = printf "%s" $ctx.name }}
{{- else }}
  {{- $name = printf ".%s.%s" $client_namespace $ctx.name }}
{{- end }}
{{- $partitions := 3 }}
{{- $replicas := 3 }}
{{- $retention := 7200000 }}
{{- $cleanup := "compact" }}
{{- $segment := 1073741824 }}
{{- if eq $type "shared" }}
  {{- $partitions = 1 }}
  {{- $replicas = 1 }}
{{- end }}
{{- if eq $type "repartition" }}
  {{- $cleanup = "delete" }}
  {{- $retention = -1 }}
  {{- $segment = 52428800 }}
{{- else if eq $type "changelog" }}
  {{- $cleanup = "compact" }}
  {{- $retention = 604800000 }}
  {{- $segment = 1073741824 }}
{{- end }}
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaTopic
metadata:
  name: {{ $name }}
  namespace: {{ $namespace }}
  labels:
    strimzi.io/cluster: {{ $ctx.kafka_cluster }}
spec:
  partitions: {{ $partitions }}
  replicas: {{ $replicas }}
  topicName: {{ $name }}
  config:
    retention.ms: {{ $retention }}
    cleanup.policy: {{ $cleanup | quote }}
    segment.bytes: {{ $segment }}
---
{{- end }}
