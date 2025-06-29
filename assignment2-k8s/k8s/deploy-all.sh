#!/bin/bash

echo "🧹 Cleaning up existing deployments..."

# If a previous Helm release exists, uninstall it to ensure a clean slate
helm uninstall nodejs-mysql -n nodejs-crud 2>/dev/null || true

# Also attempt to delete the namespaces in case they remain after an uninstall
kubectl delete namespace mysql nodejs-crud 2>/dev/null || true

echo "⏳ Waiting for cleanup to complete..."
sleep 10

echo "🏗️  Creating namespaces and deploying resources..."

# Deploy in the correct order

echo "📡 Deploying Ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "⏳ Waiting for Ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "⏳ Waiting for Ingress admission webhook to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=complete job \
  --selector=app.kubernetes.io/component=admission-webhook \
  --timeout=120s 2>/dev/null || echo "⚠️  Admission webhook job not found, continuing..."

# Wait a bit more for the webhook service to be fully available
echo "⏳ Giving webhook service additional time to stabilize..."
sleep 15

echo "📊 Deploying Metrics-server..."
kubectl apply -f metrics-server.yaml
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system \
  --type json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo "🚀 Deploying or upgrading Helm chart..."
# The chart root is the directory where this script resides
CHART_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install/upgrade the Helm release
helm upgrade --install nodejs-mysql "$CHART_DIR" \
  --namespace nodejs-crud \
  --create-namespace

echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=240s

echo "⏳ Waiting for Node.js app to be ready..."
kubectl wait --for=condition=ready pod -l app=nodejs-crud -n nodejs-crud --timeout=240s

echo "✅ Deployment complete!"
echo ""
echo "📊 Check the status:"
echo "kubectl get pods -n mysql"
echo "kubectl get pods -n nodejs-crud"
echo "kubectl get svc -n mysql"
echo "kubectl get svc -n nodejs-crud"
echo "kubectl get hpa -n nodejs-crud"
echo "kubectl get ingress -n nodejs-crud"
echo ""
echo "🌐 Test the application:"
echo "curl http://localhost/" 