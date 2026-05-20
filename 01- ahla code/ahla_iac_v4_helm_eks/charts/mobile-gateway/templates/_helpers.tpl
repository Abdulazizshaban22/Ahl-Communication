
{{- define "mobile-gateway.labels" -}}
app.kubernetes.io/name: {{ include "mobile-gateway.name" . }}
helm.sh/chart: {{ include "mobile-gateway.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "mobile-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mobile-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "mobile-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "mobile-gateway.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "mobile-gateway.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "mobile-gateway.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
