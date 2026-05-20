#!/usr/bin/env bash
set -euo pipefail
SEL=${1:-s1}
DOM=${2:-ahla.com}
OUT=./dkim-${SEL}-${DOM}
mkdir -p "$OUT"
openssl genrsa -out "$OUT/private.key" 2048
openssl rsa -in "$OUT/private.key" -pubout -out "$OUT/public.key"
echo "TXT ${SEL}._domainkey.${DOM}  v=DKIM1; k=rsa; p=$(awk 'NF && $1 !~ /^-/' $OUT/public.key | tr -d '\n')"
echo "Private key at: $OUT/private.key (load into your signer)"
