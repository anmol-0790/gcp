# GCP React Modules - Deployment Summary

## 🚀 Quick Overview

Two React modules (Login & Dashboard) deployed to GCP Compute Engine on a single VM with path-based routing.

## 📁 Project Structure

```
gcp/
├── login/                    # Login Module (React + TypeScript)
├── dashboard/                # Dashboard Module (React + TypeScript)
├── deploy-login.sh          # Deploy Login Module
├── deploy-dashboard.sh      # Deploy Dashboard Module
└── README.md
```

## 🛠️ Technology Stack

- **Frontend**: React 18 + TypeScript
- **Build**: Create React App
- **Web Server**: Nginx (direct static serving)
- **Cloud**: Google Cloud Platform Compute Engine
- **VM**: Ubuntu 22.04 LTS (e2-micro)
- **Deployment**: Shell scripts + gcloud CLI

## 🚀 Deployment Process

### 1. Deploy Login Module

```bash
./deploy-login.sh
```

- Creates VM if needed
- Builds React app locally
- Copies to `/var/www/html/login/`
- Configures nginx for `/login/` path

### 2. Deploy Dashboard Module

```bash
./deploy-dashboard.sh
```

- Uses existing VM
- Builds React app locally
- Copies to `/var/www/html/dashboard/`
- Updates nginx for `/dashboard/` path

## 🌐 Access URLs

- **Login**: `http://VM_IP/login/`
- **Dashboard**: `http://VM_IP/dashboard/`
- **Health Check**: `http://VM_IP/health`
- **Root**: `http://VM_IP/` (redirects based on last deployed module)

## ⚙️ Configuration

### VM Details

- **Name**: `invoapp-vm`
- **Type**: e2-micro (1 vCPU, 1GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Zone**: us-central1-a

### React Build Config

```json
// login/package.json
{
  "homepage": "/login"
}

// dashboard/package.json
{
  "homepage": "/dashboard"
}
```

### Nginx Path Routing

```nginx
location /login/ {
    root /var/www/html;
    try_files $uri $uri/ /login/index.html;
}

location /dashboard/ {
    root /var/www/html;
    try_files $uri $uri/ /dashboard/index.html;
}
```

## 💰 Cost

- **Single VM**: ~$6/month
- **Free Tier**: e2-micro eligible
- **Auto-shutdown**: Available for cost savings

## 🔧 Prerequisites

- Node.js 18+
- Google Cloud SDK (gcloud)
- GCP Project with Compute Engine API enabled

## 📋 Quick Start

1. Update `PROJECT_ID` in both scripts
2. Run `./deploy-login.sh`
3. Run `./deploy-dashboard.sh`
4. Access your modules via the provided URLs

## 🎯 Key Features

- ✅ **No Docker** - Direct nginx serving
- ✅ **Path-based Routing** - Clean URLs
- ✅ **Shared VM** - Cost effective
- ✅ **Independent Deployments** - Deploy modules separately
- ✅ **Health Checks** - Monitoring endpoints
- ✅ **Security Headers** - XSS protection, etc.

## 🔍 Troubleshooting

- **VM Name**: Must be lowercase (e.g., `invoapp-vm`)
- **Nginx Issues**: Scripts handle installation automatically
- **File Permissions**: Set automatically by scripts
- **Firewall**: HTTP traffic allowed from anywhere

---

**Ready to deploy? Run `./deploy-login.sh` and `./deploy-dashboard.sh`! 🚀**
