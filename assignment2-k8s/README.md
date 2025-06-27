```bash
kind create cluster --name symbiosis --config kind-cluster.yaml


# Install the add-ons:

# Ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Metrics-server (needed for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl patch deployment metrics-server -n kube-system \
  --type json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'


Why metrics-server? It is required for the Horizontal Pod Autoscaler to read CPU usage.

DOCKER_BUILDKIT=1 docker build -t nodejs-crud-app:1.0 .
kind load docker-image nodejs-crud-app:1.0 --name symbiosis
```