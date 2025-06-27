#!/bin/bash

echo "🧹 Cleaning up existing deployments..."

# Delete existing resources from default namespace
kubectl delete deployment mysql nodejs-crud 2>/dev/null || true
kubectl delete service mysql nodejs-crud 2>/dev/null || true
kubectl delete pvc mysql-pvc 2>/dev/null || true
kubectl delete secret mysql-secret 2>/dev/null || true
kubectl delete configmap app-config 2>/dev/null || true
kubectl delete hpa nodejs-crud-hpa 2>/dev/null || true
kubectl delete ingress nodejs-crud-ingress 2>/dev/null || true

echo "⏳ Waiting for cleanup to complete..."
sleep 10

echo "🏗️  Creating namespaces and deploying resources..."

# Deploy in the correct order
kubectl apply -f 00-namespaces.yaml

echo "📦 Deploying MySQL components to 'mysql' namespace..."
kubectl apply -f secret-mysql.yaml
kubectl apply -f pvc-mysql.yaml  
kubectl apply -f mysql-deploy.yaml

echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=120s

echo "🚀 Deploying Node.js app components to 'nodejs-crud' namespace..."
kubectl apply -f configmap-app.yaml
kubectl apply -f app-deploy.yaml
kubectl apply -f hpa.yaml
kubectl apply -f ingress.yaml

echo "⏳ Waiting for Node.js app to be ready..."
kubectl wait --for=condition=ready pod -l app=nodejs-crud -n nodejs-crud --timeout=120s

echo "✅ Deployment complete!"
echo ""
echo "📊 Check the status:"
echo "kubectl get pods -n mysql"
echo "kubectl get pods -n nodejs-crud"
echo "kubectl get svc -n mysql"
echo "kubectl get svc -n nodejs-crud"
echo "kubectl get hpa -n nodejs-crud"
echo ""
echo "🌐 Test the application:"
echo "curl http://localhost/" 