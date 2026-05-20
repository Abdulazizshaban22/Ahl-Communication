{- define "ahla-search-service.labels" -}
app.kubernetes.io/name: { include "ahla-search-service.name" . }
helm.sh/chart: { include "ahla-search-service.chart" . }
app.kubernetes.io/instance: { .Release.Name }
app.kubernetes.io/managed-by: { .Release.Service }
app.kubernetes.io/part-of: ahla-ultra
{- end -}

{- define "ahla-search-service.name" -}
{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}
{- end -}

{- define "ahla-search-service.chart" -}
{ .Chart.Name }-{ .Chart.Version | replace "+" "_" }
{- end -}

{- define "ahla-search-service.fullname" -}
{- if .Values.fullnameOverride }
{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }
{- else }
{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }
{- end -}
{- end -}
