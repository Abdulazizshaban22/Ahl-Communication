#!/usr/bin/env bash
set -euo pipefail

# Load env
if [ ! -f ".env" ]; then
  echo "❌ لم يتم العثور على .env — انسخ .env.example إلى .env ثم حدّث القيم."
  exit 1
fi
source .env

NAMESPACE="ahla-system"

echo "🔧 Adding Helm repos…"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ >/dev/null
helm repo update >/dev/null

echo "📦 Creating namespace $NAMESPACE (if missing)…"
kubectl get ns $NAMESPACE >/dev/null 2>&1 || kubectl create ns $NAMESPACE

echo "🔐 Installing cert-manager (with CRDs)…"
helm upgrade --install cert-manager jetstack/cert-manager -n cert-manager --create-namespace \
  --set installCRDs=true

echo "🌐 Installing ingress-nginx…"
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

echo "🧭 Installing ExternalDNS…"
helm upgrade --install external-dns external-dns/external-dns -n external-dns --create-namespace \
  --set provider=aws \
  --set policy=upsert-only \
  --set registry=txt \
  --set txtOwnerId=ahla-externaldns \
  --set aws.region=${AWS_REGION} \
  --set domainFilters={${BASE_DOMAIN}} \
  --set rbac.create=true

echo "📊 Installing kube-prometheus-stack (Grafana/Prometheus)…"
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace \
  -f helm/monitoring/values.yaml

echo "🗝️ Preparing Secrets (db-url)…"
kubectl -n ${NAMESPACE} create secret generic db-url --from-literal=url="${DATABASE_URL}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "📝 Rendering values.yaml from env…"
cat > helm/values.yaml <<EOF
global:
  domain: ${BASE_DOMAIN}
  ingress:
    className: nginx
    clusterIssuer: letsencrypt-prod
  natsWS: wss://nats.${BASE_DOMAIN}:${NATS_WS_PORT}
  contentApi: https://api.${BASE_DOMAIN}
  auth:
    issuer: ${KEYCLOAK_ISSUER}
    clientId: ${KEYCLOAK_CLIENT_ID}
    clientSecret: ${KEYCLOAK_CLIENT_SECRET}
    nextAuthSecret: ${NEXTAUTH_SECRET}
acme:
  email: ${ACME_EMAIL}
nats:
  replicas: 3
  wsPort: ${NATS_WS_PORT}
  allowedOrigins: ["https://*.${BASE_DOMAIN}"]
  auth: { user: "${NATS_WS_USER}", password: "${NATS_WS_PASS}" }
coturn:
  replicas: 2
  minReplicas: 2
  maxReplicas: 12
images:
  notes: ${NOTES_IMG}
  book:  ${BOOK_IMG}
  graph: ${GRAPH_IMG}
  dote:  ${DOTE_IMG}
  dash:  ${DASH_IMG}
  contentApi: ${CONTENT_IMG}
  collab: ${COLLAB_IMG}
hosts:
  notes: notes.${BASE_DOMAIN}
  book:  book.${BASE_DOMAIN}
  graph: graph.${BASE_DOMAIN}
  dote:  dote.${BASE_DOMAIN}
  dash:  dash.${BASE_DOMAIN}
  api:   api.${BASE_DOMAIN}
deploy:
  collab: true
EOF

echo "📦 Deploying ahla-cloud (issuer + NATS + CoTURN + KEDA)…"
helm upgrade --install ahla-cloud helm/ahla-cloud -n ${NAMESPACE} --create-namespace -f helm/values.yaml

echo "🚀 Deploying ahla-suite (apps + content-api)…"
helm upgrade --install ahla-suite helm/ahla-suite -n ${NAMESPACE} -f helm/values.yaml

echo "✅ Done! Verify:"
echo "  kubectl -n ${NAMESPACE} get pods"
echo "  kubectl -n ${NAMESPACE} get ingress"
