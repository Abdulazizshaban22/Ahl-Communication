{- define "ahla-asr-service.labels" -}
app.kubernetes.io/name: { include "ahla-asr-service.name" . }
helm.sh/chart: { include "ahla-asr-service.chart" . }
app.kubernetes.io/instance: { .Release.Name }
app.kubernetes.io/managed-by: { .Release.Service }
app.kubernetes.io/part-of: ahla-ultra
{- end -}

{- define "ahla-asr-service.name" -}
{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}
{- end -}

{- define "ahla-asr-service.chart" -}
{ .Chart.Name }-{ .Chart.Version | replace "+" "_" }
{- end -}

{- define "ahla-asr-service.fullname" -}
{- if .Values.fullnameOverride }
{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }
{- else }
{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }
{- end -}
{- end -}
