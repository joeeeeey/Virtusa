# DevOps Technical Assignment – Portfolio

This repository contains **two independent solutions** matching the CC4.0 DevOps assignment.

| Assignment | Folder | One-click README |
|------------|--------|------------------|
| **1. AWS Cloud Migration** – provision a 3-tier AWS stack with Terraform and host a Node.js MySQL CRUD app | `assignment1-aws-cloud-migration` | [Detailed guide](assignment1-aws-cloud-migration/README.md) |
| **2. Kubernetes Deployment** – run the same app on a local k8s cluster (Minikube) with manifests for Deploy/Service/Ingress/PV | `assignment2-k8s` | [Detailed guide](assignment2-k8s/README.md) |

---

## Quick Glance – What Works 📸

### Assignment 1 highlights

* ALB URL outputs automatically after `terraform apply` and shows the CRUD UI.
* ASG uses Spot + On-Demand, nodes run Ubuntu 22 + Node 20.
* RDS MySQL is bootstrapped with the required `users` table on first boot.
* Screenshots live in `assignment1-aws-cloud-migration/terraform/screenshot/`.

![ALB healthy](assignment1-aws-cloud-migration/terraform/screenshot/alb-resource-map.png)

### Assignment 2 highlights

* Minikube manifests include Deployment, Service, Ingress and PVC.
* A liveness probe checks the root path returns **200**.
* Example of horizontal scaling via `kubectl scale` and notes on HPA.

---

## How to reproduce quickly

```bash
# Assignment 1 – AWS
cd assignment1-aws-cloud-migration/terraform/envs/dev
terraform init            # backend config if you want S3 state
terraform plan
terraform apply -auto-approve

# Assignment 2 – Kubernetes
cd assignment2-k8s
minikube start
kubectl apply -f k8s/
```

For full instructions, diagrams and cost/scaling notes please follow the links in the table above.
