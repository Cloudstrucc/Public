# 🚀 Aries Canada Deployment Guide

This repository provides everything you need to deploy an Aries-based DID solution, mediator for Bifold wallets, and integration with Microsoft Entra Verified ID — fully hosted in Canada.

---

## 📦 Components Overview

* **Sandbox ARM templates** (`infra/sandbox-arm/`): Quick single-VM deployment
* **Production ARM templates** (`infra/prod-arm/`): Secure multi-VM deployment with VNet + NSG
* **Docker Compose** (`docker/`): ACA-Py agent & mediator
* **Bridge Service** (`bridge-service/`): Issue Verified IDs to wallets
* **Verified ID Manifest & Schema** (`verified-id/`)
* **Deployment Scripts** (`scripts/`)
* **GitHub Actions Workflow** (`.github/workflows/deploy.yml`)

---

## 🔨 How to Deploy (Sandbox)

```bash
cd scripts
chmod +x deploy-sandbox.sh
./deploy-sandbox.sh
```

* Logs in to your Azure subscription
* Creates a resource group & sandbox VM in Canada Central
* Opens required ports for ACA-Py agent & mediator

---

## 🚀 How to Deploy (Production)

```bash
az deployment group create \
  --resource-group ariesCanadaRG \
  --template-file infra/prod-arm/azuredeploy.json \
  --parameters infra/prod-arm/azuredeploy.parameters.json
```

* Deploys secure infrastructure: VNet, NSG, Key Vault, VM
* Sets up networking for production readiness

---

## 🐳 How to Start Agent & Mediator

SSH into your VM (sandbox or production) and run:

```bash
sudo apt update && sudo apt install -y docker.io
cd ~/aries-canada/docker
docker-compose up -d
```

---

## 🔗 How to Issue Invitations for Bifold

From your server (or local if ports are open):

```bash
./scripts/create-bifold-invitation.sh
```

---

## 🛡️ How to Run the Bridge Service

On your VM or local environment with Node.js installed:

```bash
cd bridge-service
cp .env.example .env
# Edit .env with your VERIFIED_ID_AUTHORITY and ENTRA_ACCESS_TOKEN
npm install
npm start
```

---

## ✅ CI/CD Pipeline

A GitHub Actions workflow is included at `.github/workflows/deploy.yml` to automate deployments when changes are pushed to `main`.
