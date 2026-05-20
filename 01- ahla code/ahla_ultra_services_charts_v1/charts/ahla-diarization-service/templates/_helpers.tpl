{- define "ahla-diarization-service.labels" -}
app.kubernetes.io/name: { include "ahla-diarization-service.name" . }
helm.sh/chart: { include "ahla-diarization-service.chart" . }
app.kubernetes.io/instance: { .Release.Name }
app.kubernetes.io/managed-by: { .Release.Service }
app.kubernetes.io/part-of: ahla-ultra
{- end -}

{- define "ahla-diarization-service.name" -}
{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}
{- end -}

{- define "ahla-diarization-service.chart" -}
{ .Chart.Name }-{ .Chart.Version | replace "+" "_" }
{- end -}

{- define "ahla-diarization-service.fullname" -}
{- if .Values.fullnameOverride }
{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }
{- else }
{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }
{- end -}
{- end -}
