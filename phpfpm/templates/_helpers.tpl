{{/* **********************************
Expand the name of the chart.
*/}}
{{- define "phpfpm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* **********************************
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "phpfpm.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* **********************************
Create chart name and version as used by the chart label.
*/}}
{{- define "phpfpm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* **********************************
Common labels
*/}}
{{- define "phpfpm.labels" -}}
helm.sh/chart: {{ include "phpfpm.chart" . }}
{{ include "phpfpm.selectorLabels" . }}
{{/* istio-telemetry needs app label to be set to podname(fullname) */}}
app: {{ include "phpfpm.fullname" . }}
{{/* app: {{ .Release.Name }} */}}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* **********************************
Selector labels
*/}}
{{- define "phpfpm.selectorLabels" -}}
{{/* app.kubernetes.io/name: {{ include "phpfpm.name" . }} */}}
app.kubernetes.io/name: {{ include "phpfpm.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}




{{/*
Recursive Rename
  add prefix to name: elements recursively
  output: yaml
*/}}
{{- define "phpfpm.recursiveRename" -}}
{{/* parameters: prefix, values */}}
{{- $prefix := .prefix -}}
{{- $values := .values -}}

{{- if or (kindIs "slice" $values) (kindIs "array" $values) -}}
  {{- $newList := list -}}
  {{- range $v := $values -}}
    {{- if (kindIs "map" $v) -}}
      {{- $newList = append $newList (include "phpfpm.recursiveRename" (dict "prefix" $prefix "values" $v) | fromYaml ) -}}
    {{- else if (kindIs "slice" $v) -}}
      {{- $newList = append $newList (include "phpfpm.recursiveRename" (dict "prefix" $prefix "values" $v) | fromYamlArray ) -}}
    {{- else -}}
      {{- $newList = append $newList $v -}}
    {{- end -}}
  {{- end -}}
  {{- $newList | toYaml -}}

{{- else if kindIs "map" $values -}}
  {{- $newDict := dict -}}
  {{- range $k, $v := $values -}}
    {{- if eq $k "name" -}}
      {{- if $prefix -}}
        {{- $_ := set $newDict $k (printf "%s-%s" $prefix $v) -}}
      {{- else -}}
		{{- $_ := set $newDict $k $v -}}
      {{- end -}}
      {{/* {{- $_ := set $newDict $k (printf "%s-%s" "abcde" $v) -}} */}}
    {{- else -}}
      {{- if (kindIs "map" $v) -}}
        {{- $_ := set $newDict $k (include "phpfpm.recursiveRename" (dict "prefix" $prefix "values" $v) | fromYaml ) -}}
      {{- else if (kindIs "slice" $v) -}}
        {{- $_ := set $newDict $k (include "phpfpm.recursiveRename" (dict "prefix" $prefix "values" $v) | fromYamlArray ) -}}
      {{- else -}}
        {{- $_ := set $newDict $k $v -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $newDict | toYaml -}}

{{- else -}}
  {{- $values | toYaml -}}
{{- end -}}
{{- end -}}





