# Assignment 2 – Kubernetes Deployment with Proper Namespace Organization

## 🎯 Project Overview

This assignment demonstrates the containerization and deployment of a Node.js CRUD application on a local Kubernetes cluster using **kind (Kubernetes in Docker)**. The project showcases modern Kubernetes best practices including:

- **Namespace Isolation**: Proper separation of database and application components
- **Health Checks**: Liveness and readiness probes for reliability
- **Horizontal Pod Autoscaling (HPA)**: Automatic scaling based on CPU utilization
- **Cross-Namespace Communication**: Secure service discovery between namespaces
- **Persistent Storage**: Database persistence using Persistent Volume Claims
- **Ingress Configuration**: External access management

## 🏗️ Architecture & Namespace Design

![Architecture Diagram](diagrams/k8s-architecture.png)

### **Namespace Organization**
```
┌─────────────────────────────────────────┐
│              kind Cluster               │
├─────────────────────────────────────────┤
│  📦 mysql namespace                     │
│  ├── MySQL Deployment                   │
│  ├── MySQL Service                      │
│  ├── MySQL PVC (5Gi storage)           │
│  └── MySQL Secret                       │
├─────────────────────────────────────────┤
│  🚀 nodejs-crud namespace               │
│  ├── Node.js CRUD Deployment            │
│  ├── Node.js Service                    │
│  ├── Application ConfigMap              │
│  ├── MySQL Secret Reference             │
│  ├── Horizontal Pod Autoscaler          │         │
└─────────────────────────────────────────┘
```

### **Cross-Namespace Communication**
- Node.js app connects to MySQL using FQDN: `mysql.mysql.svc.cluster.local:3306`
- Secrets are duplicated in each namespace for security isolation
- Services are exposed only within their respective namespaces

## 🗂️ File Structure
```
assignment2-k8s/
├── k8s/                  # Helm chart + helper script
│   ├── Chart.yaml        # Chart metadata
│   ├── values.yaml       # Default configuration values
│   ├── templates/        # Kubernetes manifests (templated)
│   │   ├── namespaces.yaml
│   │   ├── mysql-*       # MySQL Deployment / PVC / Config / Secret
│   │   ├── app-*         # Node.js Deployment / Service / ConfigMap / Secret
│   │   ├── hpa.yaml      # Horizontal Pod Autoscaler
│   │   └── ingress.yaml  # Ingress resource
│   └── deploy-all.sh  # Automates ingress-nginx setup + Helm release
├── screenshots/          # Documentation screenshots
├── app/                  # Node.js CRUD source & Dockerfile
├── kind-cluster.yaml     # Kind cluster configuration
└── README.md             # This documentation
```


## 🎯 Assignment Objectives Achieved

- ✅ **Containerization**: Node.js CRUD app properly containerized
- ✅ **Namespace Organization**: MySQL and app components separated
- ✅ **Health Checks**: Liveness and readiness probes implemented
- ✅ **Scaling**: HPA configured for automatic horizontal scaling
- ✅ **Persistence**: MySQL data persisted using PVC
- ✅ **Service Discovery**: Cross-namespace communication established
- ✅ **Ingress**: External access configured via Ingress controller
- ✅ **Security**: Proper secret management and namespace isolation
- ✅ **Continuous Deployment**: By run `make deploy`


## 🔧 Key Kubernetes Features Implemented

### 1. **Health Checks**
```yaml
livenessProbe:
  httpGet:
    path: "/"
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: "/"
    port: 3000
  initialDelaySeconds: 15
  periodSeconds: 5
```

### 2. **Horizontal Pod Autoscaler**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nodejs-crud-hpa
  namespace: nodejs-crud
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nodejs-crud
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### 3. **Persistent Storage**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: mysql
spec:
  accessModes: 
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

### 4. **Cross-Namespace Service Discovery**
- ConfigMap references MySQL service as: `mysql.mysql.svc.cluster.local`
- Enables secure communication between namespaces
- Maintains service isolation and security boundaries

## 🔄 Scaling Demonstration

To test the HPA functionality:

```bash
# Generate load to trigger scaling
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- \
  /bin/sh -c "while sleep 0.01; do wget -q -O- http://nodejs-crud.nodejs-crud.svc.cluster.local; done"

# Watch HPA in action
kubectl get hpa -n nodejs-crud -w
```

## 📈 Monitoring & Observability

### Basic Monitoring
```bash
# Monitor resource usage
kubectl top pods -n nodejs-crud
kubectl top pods -n mysql

# Watch scaling events
kubectl get events -n nodejs-crud --sort-by='.lastTimestamp'
```

## 🚀 Quick Start

### Prerequisites
- Docker Desktop or Docker Engine
- kind (Kubernetes in Docker)
- kubectl CLI tool

### 1. One-Click Provision & Deploy
```bash
make init   # creates kind cluster, builds image, loads it and installs Helm chart
```

## 📊 Verification & Testing

### Check Deployment Status

**Screenshot 1: Cluster Overview**
```bash
kubectl get nodes
kubectl get namespaces
```
![Cluster Overview](screenshots/namespaces.png)

**Screenshot 2: MySQL Namespace Resources**
```bash
kubectl get all,pvc,secrets -n mysql
```
![MySQL Namespace Resources](screenshots/mysql-pvc-secrets.png)

**Screenshot 3: Node.js CRUD Namespace Resources**  
```bash
kubectl get all,configmap,secrets,ingress,hpa -n nodejs-crud
```
![Node.js CRUD Namespace Resources](screenshots/NODEJS-CRUD-resources.png)

### Application Testing

**Screenshot 4: Application Access**
```bash
curl -I http://localhost/
curl http://localhost/ | head -20
```
![Application Access Testing](screenshots/APPLICATION-ACCESS-TESTING.png)


## 🧹 Cleanup

```bash
# Remove Helm release & namespaces
# Destroy the kind cluster
make destroy
```
