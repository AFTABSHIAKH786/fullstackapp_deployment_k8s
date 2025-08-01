{{/*
Expand the name of the chart.
*/}}
{{- define "userapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "userapp.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "userapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "userapp.labels" -}}
helm.sh/chart: {{ include "userapp.chart" . }}
{{ include "userapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "userapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "userapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "userapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "userapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name for frontend.
*/}}
{{- define "userapp.frontend.fullname" -}}
{{- printf "%s-frontend" (include "userapp.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name for backend.
*/}}
{{- define "userapp.backend.fullname" -}}
{{- printf "%s-backend" (include "userapp.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name for postgres.
*/}}
{{- define "userapp.postgres.fullname" -}}
{{- printf "%s-postgres" (include "userapp.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "userapp.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "userapp.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "userapp.backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "userapp.name" . }}-backend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Postgres selector labels
*/}}
{{- define "userapp.postgres.selectorLabels" -}}
app.kubernetes.io/name: {{ include "userapp.name" . }}-postgres
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "userapp.frontend.labels" -}}
helm.sh/chart: {{ include "userapp.chart" . }}
{{ include "userapp.frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "userapp.backend.labels" -}}
helm.sh/chart: {{ include "userapp.chart" . }}
{{ include "userapp.backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Postgres labels
*/}}
{{- define "userapp.postgres.labels" -}}
helm.sh/chart: {{ include "userapp.chart" . }}
{{ include "userapp.postgres.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }} 