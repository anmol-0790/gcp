# GCP React Modules Deployment

This project contains two React modules that can be deployed to Google Cloud Platform (GCP) Compute Engine on the same VM with path-based routing.

## Project Structure

```
gcp/
├── login/                    # Login Module (React + TypeScript)
│   ├── src/
│   │   ├── components/
│   │   │   └── LoginForm.tsx
│   │   ├── App.tsx
│   │   ├── App.css
│   │   ├── index.tsx
│   │   └── index.css
│   ├── public/
│   │   └── index.html
│   ├── package.json          # Contains "homepage": "/login"
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
├── dashboard/                # Dashboard Module (React + TypeScript)
│   ├── src/
│   │   ├── components/
│   │   │   ├── DashboardHeader.tsx
│   │   │   ├── WelcomeSection.tsx
│   │   │   └── FeatureCard.tsx
│   │   ├── App.tsx
│   │   ├── App.css
│   │   ├── index.tsx
│   │   └── index.css
│   ├── public/
│   │   └── index.html
│   ├── package.json          # Contains "homepage": "/dashboard"
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .dockerignore
├── deploy-login.sh          # Deploy Login Module to shared VM
├── deploy-dashboard.sh      # Deploy Dashboard Module to shared VM
└── README.md
```

## Features

### Login Module

- **Modern React with TypeScript**
- **Responsive Design** - Works on desktop and mobile
- **Form Validation** - Email and password validation
- **Security Features** - Input sanitization, XSS protection
- **Health Check** - `/health` endpoint for monitoring
- **Docker Ready** - Multi-stage build with Nginx
- **Path-based Routing** - Configured for `/login` path

### Dashboard Module

- **Modern React with TypeScript**
- **Responsive Design** - Mobile-first approach
- **Component Architecture** - Reusable components
- **Health Check** - `/health` endpoint for monitoring
- **Docker Ready** - Multi-stage build with Nginx
- **Path-based Routing** - Configured for `/dashboard` path

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Google Cloud SDK (`gcloud`)
- GCP Project with Compute Engine API enabled

### 1. Clone and Setup

```bash
git clone <your-repo>
cd gcp
```

### 2. Update Configuration

Edit the deployment scripts and update:

```bash
PROJECT_ID="your-actual-gcp-project-id"  # Update this
ZONE="us-central1-a"                     # Your preferred zone
```

### 3. Deploy to GCP

#### Deploy Modules to Shared VM 🎯

Deploy modules to the same VM with path-based routing:

```bash
# Deploy Login Module first
./deploy-login.sh

# Deploy Dashboard Module (uses same VM)
./deploy-dashboard.sh
```

**Access URLs:**

- **Login Module**: `http://VM_IP/login/`
- **Dashboard Module**: `http://VM_IP/dashboard/`
- **Health Check**: `http://VM_IP/health`
- **Root**: `http://VM_IP/` (redirects based on last deployed module)

## What the Scripts Do

### `deploy-login.sh` - Deploy Login Module

1. **Builds** the Login React application locally
2. **Creates** VM if it doesn't exist, or uses existing VM
3. **Installs** Nginx if needed
4. **Copies** Login built files to `/var/www/html/login/`
5. **Configures** Nginx for `/login/` path routing
6. **Sets up** proper file permissions
7. **Provides** working URL for Login module

### `deploy-dashboard.sh` - Deploy Dashboard Module

1. **Builds** the Dashboard React application locally
2. **Uses** existing VM (same as login)
3. **Installs** Nginx if needed
4. **Copies** Dashboard built files to `/var/www/html/dashboard/`
5. **Configures** Nginx for `/dashboard/` path routing
6. **Sets up** proper file permissions
7. **Provides** working URL for Dashboard module

## Local Development

### Build Individual Modules

```bash
# Build Login Module
./build-login.sh

# Build Dashboard Module
./build-dashboard.sh

# Build Both Modules
./build-all.sh
```

### Manual Local Build

```bash
# Login Module
cd login
npm install
npm run build
docker build -t login-module:latest .

# Dashboard Module
cd dashboard
npm install
npm run build
docker build -t dashboard-module:latest .
```

### Run Locally with Docker

```bash
# Login Module
cd login
docker run -p 3001:80 login-module:latest
# Access: http://localhost:3001

# Dashboard Module
cd dashboard
docker run -p 3002:80 dashboard-module:latest
# Access: http://localhost:3002
```

## GCP Deployment Details

### Unified Deployment (`deploy-unified.sh`)

1. **Builds both React apps locally** with correct homepage configuration
2. **Creates single GCP VM instance** (e2-micro, Ubuntu 22.04)
3. **Configures firewall** (allows HTTP traffic)
4. **Sets up Nginx reverse proxy** with path routing:
   - `/login/` → Login Module (serves from `/var/www/html/login/`)
   - `/dashboard/` → Dashboard Module (serves from `/var/www/html/dashboard/`)
   - `/` → Redirects to `/login/`
5. **Handles static files correctly**:
   - `/login/static/` → serves from `/var/www/html/login/static/`
   - `/dashboard/static/` → serves from `/var/www/html/dashboard/static/`
6. **Copies files** to VM via `gcloud compute scp`
7. **Provides unified access URLs**

### Shared VM Benefits

- Both modules share the same VM (`invoapp-vm`)
- Path-based routing: `/login/` and `/dashboard/`
- Cost-effective single VM deployment
- Easy management and monitoring

### VM Configuration

- **Machine Type**: e2-micro (1 vCPU, 1GB RAM)
- **OS**: Ubuntu 22.04 LTS
- **Nginx**: Web server for static file serving
- **Ports**: 80 (HTTP)
- **Firewall**: HTTP traffic allowed from anywhere
- **VM Name**: `invoapp-vm` (shared by both modules)

### Access Your Deployed Modules

#### Shared VM Deployment

```
🎉 Login Module deployed successfully!
=============================================
📋 Deployment Details:
  • VM Instance: invoapp-vm
  • Zone: us-central1-a
  • External IP: 34.56.155.203

🌐 Access URLs:
  • Login Module: http://34.56.155.203/login/
  • Dashboard Module: http://34.56.155.203/dashboard/
  • Health Check: http://34.56.155.203/health
  • Root (redirects based on last deployed module): http://34.56.155.203
```

## Path-based Routing Configuration

### React Build Configuration

Both modules are configured with the `homepage` field in `package.json`:

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

This ensures that:

- Static files are built with correct paths (`/login/static/`, `/dashboard/static/`)
- HTML files reference the correct asset paths
- Nginx can serve files from module-specific directories

### Nginx Configuration

The unified deployment uses nginx location blocks to handle module-specific routing:

```nginx
# Handle static files for login module
location ~* ^/login/static/(.+)$ {
    root /var/www/html;
    try_files /login/static/$1 =404;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Handle static files for dashboard module
location ~* ^/dashboard/static/(.+)$ {
    root /var/www/html;
    try_files /dashboard/static/$1 =404;
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Login Module
location /login/ {
    root /var/www/html;
    try_files $uri $uri/ /login/index.html;
}

# Dashboard Module
location /dashboard/ {
    root /var/www/html;
    try_files $uri $uri/ /dashboard/index.html;
}
```

## Management Commands

### SSH into VM

```bash
# Unified deployment
gcloud compute ssh unified-modules-vm --zone=us-central1-a

# Individual deployments
gcloud compute ssh login-module-vm --zone=us-central1-a
gcloud compute ssh dashboard-module-vm --zone=us-central1-a
```

### View Logs

```bash
# SSH into VM first

# Unified deployment
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Individual deployments
docker logs login-app
docker logs dashboard-app
```

### Delete VMs

```bash
# Unified deployment
gcloud compute instances delete unified-modules-vm --zone=us-central1-a

# Individual deployments
gcloud compute instances delete login-module-vm --zone=us-central1-a
gcloud compute instances delete dashboard-module-vm --zone=us-central1-a
```

### List All VMs

```bash
gcloud compute instances list
```

## Security Features

### Application Level

- **Input Validation** - Email format, password requirements
- **XSS Protection** - Input sanitization
- **Session Management** - Demo session handling
- **HTTPS Ready** - Easy to add SSL certificates

### Infrastructure Level

- **Firewall Rules** - Only HTTP traffic allowed
- **Docker Isolation** - Containerized applications (individual deployments)
- **Nginx Security Headers** - X-Frame-Options, X-Content-Type-Options, etc.
- **Health Checks** - Monitoring endpoints
- **Reverse Proxy** - Nginx handles routing and security (unified deployment)

## Troubleshooting

### Common Issues

#### 1. Permission Denied

```bash
chmod +x *.sh
```

#### 2. GCP Authentication

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### 3. Build Failures

```bash
# Check Node.js version
node --version  # Should be 18+

# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

#### 4. Static Files Not Loading (404)

This usually happens when the `homepage` configuration is missing or incorrect:

```bash
# Check package.json has correct homepage
cat login/package.json | grep homepage
cat dashboard/package.json | grep homepage

# Rebuild with correct configuration
cd login && npm run build
cd dashboard && npm run build
```

#### 5. Docker Issues

```bash
# Check Docker is running
docker --version

# Build with verbose output
docker build --no-cache -t login-module:latest .
```

#### 6. VM Connection Issues

```bash
# Check VM status
gcloud compute instances describe unified-modules-vm --zone=us-central1-a

# Check firewall rules
gcloud compute firewall-rules list
```

#### 7. Nginx Issues (Unified Deployment)

```bash
# SSH into VM
sudo nginx -t  # Test configuration
sudo systemctl status nginx
sudo systemctl restart nginx
```

### Health Checks

Each module has a health check endpoint:

- **Unified**: `http://EXTERNAL_IP/health` (shows both modules)
- **Individual**: `http://EXTERNAL_IP/health` (per module)

### Monitoring

```bash
# Check VM status
gcloud compute instances list

# Check if services are running (SSH into VM)
# Unified deployment
sudo systemctl status nginx

# Individual deployments
docker ps
```

## Cost Optimization

### VM Sizing

- **e2-micro**: Free tier eligible (1 vCPU, 1GB RAM)
- **e2-small**: $6.11/month (1 vCPU, 2GB RAM)
- **e2-medium**: $12.22/month (1 vCPU, 4GB RAM)

### Cost Comparison

- **Shared VM Deployment**: 1 VM = ~$6/month
- **Separate VMs**: 2 VMs = ~$12/month

### Auto-shutdown

Add to startup script for cost savings:

```bash
# Shutdown VM at 6 PM daily
echo "0 18 * * * shutdown -h now" | crontab -
```

## Next Steps

### Production Considerations

1. **SSL Certificates** - Add HTTPS support
2. **Load Balancing** - For high availability
3. **Monitoring** - Cloud Monitoring integration
4. **Backup Strategy** - Regular snapshots
5. **CI/CD Pipeline** - Automated deployments
6. **Database Integration** - Add persistent storage
7. **Authentication** - Real user management

### Scaling Options

1. **Instance Groups** - Multiple VM instances
2. **Cloud Run** - Serverless containers
3. **Kubernetes** - Container orchestration
4. **Cloud Functions** - Serverless functions

## Support

For issues or questions:

1. Check the troubleshooting section
2. Review GCP documentation
3. Check Docker and React logs
4. Verify firewall and network settings
