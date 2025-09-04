# Internal Service – Helm + GitOps Deployment

This repository contains a simple **Go-based web application** deployed with **Helm** and configured for **GitOps workflows with Kustomize**.  
It is designed for easy, secure, and GitOps-friendly deployments to Kubernetes.

---

##  Features

- Go web app listening on **port 8080**
- `/` → returns all environment variables in JSON
- `/healthz` → health check endpoint for probes
- Helm chart (`internal-service`) with:
  - Replicated deployment (≥3 pods)
  - HPA autoscaling
  - Pod anti-affinity
  - Secure `securityContext` (non-root, read-only FS, no privilege escalation)
  - Configurable `hub`, `image`, `tag`, `prod`, `env`, `resources`
- Environments:
  - **dev** → `PROD=false`
  - **prod** → `PROD=true`
- GitOps with Kustomize overlays (`dev` / `prod`)
- Works locally with **kind** (Kubernetes in Docker)

---

##  Docker Image

Published at:  
 [Docker Hub – mhristov/internal-service](https://hub.docker.com/r/mhristov/internal-service)

To build & push manually:
```bash
docker build -t mhristov/internal-service:latest .
docker push mhristov/internal-service:latest
```

---


## Prerequisites

- Docker
- kubectl
- kind
- Helm
- Kustomize

# Setup kind Cluster
Simple 1-node cluster
```bash
kind create cluster --name internal-services
```
Multi-node cluster (recommended for anti-affinity)

Create kind-config.yaml:
```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

Then:
```bash
kind create cluster --name internal-services --config kind-config.yaml
```

Verify:
```bash
kubectl get nodes
```
# Deploy with Helm
- # Development (PROD=false)
```bash
helm install internal-service ./internal-service \
  --set prod=false \
  --set image.hub=docker.io \
  --set image.repository=mhristov/internal-service \
  --set image.tag=latest
```
- # Production (PROD=true)
```bash
helm install internal-service-prod ./internal-service \
  --set prod=true \
  --set image.hub=docker.io \
  --set image.repository=mhristov/internal-service \
  --set image.tag=latest
```
- # Upgrade if release already exists:
```bash
helm template internal-service ./internal-service > gitops/base/internal-service.yaml
```
# GitOps with Kustomize
- Render Helm manifests into gitops/base/
```bash
helm template internal-service ./internal-service > gitops/base/internal-service.yaml
```
## Apply overlay
  ## dev
```bash
kubectl apply -k gitops/overlays/dev
```
  ## prod
```bash
 kubectl apply -k gitops/overlays/prod
```
---
#  Verify Deployment
```bash 
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl get hpa
```
- Port-forward to access the app:
```bash
kubectl port-forward svc/internal-service 8080:8080
```
Then open:

App: http://localhost:8080
 → shows env vars in JSON

Health: http://localhost:8080/healthz
 → returns ok
 