#!/bin/bash

# Dashboard Module Deployment Script
# Deploys Dashboard Module to its own VM

set -e

# Configuration - UPDATE THESE VALUES
PROJECT_ID="simplifyinvoice-uat-471012"  # <<< UPDATE THIS
ZONE="us-central1-a"
INSTANCE_NAME="invoapp-vm"
MACHINE_TYPE="e2-micro"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Dashboard Module Deployment${NC}"
echo "============================================="

# Check if project ID is set
if [ "$PROJECT_ID" == "your-actual-gcp-project-id" ]; then
    echo -e "${RED}❌ Error: Please update PROJECT_ID in this script${NC}"
    exit 1
fi

# Set project
gcloud config set project $PROJECT_ID

# Step 1: Build Dashboard Module locally
echo -e "${YELLOW}📦 Step 1: Building Dashboard Module locally...${NC}"

cd dashboard
npm install
npm run build
cd ..

echo -e "${GREEN}✅ Dashboard Module built successfully${NC}"

# Step 2: Enable APIs
echo -e "${YELLOW}📡 Step 2: Enabling GCP APIs...${NC}"
gcloud services enable compute.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"

# Step 3: Check if VM exists, create if not
echo -e "${YELLOW}🖥️  Step 3: Checking VM instance...${NC}"

if ! gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID &>/dev/null; then
    echo "VM not found. Creating new VM instance..."
    
    # Create startup script for new VM
    cat > startup-script.sh << 'EOF'
#!/bin/bash

# Update system
apt-get update -y

# Install Nginx
apt-get install -y nginx

# Create web directory
mkdir -p /var/www/html

# Start Nginx
systemctl start nginx
systemctl enable nginx

# Wait for files to be copied
echo "Waiting for files to be copied..."
while [ ! -f "/var/www/html/index.html" ]; do
    sleep 5
done

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Configure Nginx for Dashboard Module
cat > /etc/nginx/sites-available/default << 'NGINX_EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    # Handle static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Dashboard Module - serve from /dashboard path
    location /dashboard/ {
        root /var/www/html;
        try_files $uri $uri/ /dashboard/index.html;
    }


    # Root redirect to dashboard
    location = / {
        return 301 /dashboard/;
    }

    # Health check
    location /health {
        access_log off;
        add_header Content-Type text/html;
        return 200 '<!DOCTYPE html><html><head><title>Dashboard Module - Healthy</title></head><body><h1>Dashboard Module - Healthy</h1><p>Status: OK</p></body></html>';
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
NGINX_EOF

# Test and reload nginx
nginx -t && systemctl reload nginx

echo "✅ Nginx configured and started"
EOF

    # Create VM instance
    gcloud compute instances create $INSTANCE_NAME \
        --zone=$ZONE \
        --machine-type=$MACHINE_TYPE \
        --image-family=ubuntu-2204-lts \
        --image-project=ubuntu-os-cloud \
        --tags=http-server \
        --metadata-from-file=startup-script=startup-script.sh \
        --project=$PROJECT_ID

    echo -e "${GREEN}✅ VM instance created${NC}"
    
    # Cleanup startup script
    rm -f startup-script.sh
else
    echo -e "${GREEN}✅ VM instance already exists${NC}"
fi

# Step 4: Configure firewall
echo -e "${YELLOW}🔥 Step 4: Configuring firewall...${NC}"
if ! gcloud compute firewall-rules describe allow-http --project=$PROJECT_ID &>/dev/null; then
    gcloud compute firewall-rules create allow-http \
        --allow tcp:80 \
        --source-ranges 0.0.0.0/0 \
        --target-tags http-server \
        --project=$PROJECT_ID
fi
echo -e "${GREEN}✅ Firewall configured${NC}"

# Step 5: Copy Dashboard Module files to VM
echo -e "${YELLOW}📁 Step 5: Copying Dashboard Module files to VM...${NC}"
echo "Waiting for VM to be ready..."
sleep 30

# Create directories on VM first
echo "Creating directories on VM..."
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo mkdir -p /var/www/html/dashboard && sudo chown -R $USER:$USER /var/www/html/dashboard"

# Copy Dashboard Module build files
echo "Copying Dashboard Module build files..."
gcloud compute scp --recurse ./dashboard/build/* $INSTANCE_NAME:/var/www/html/dashboard/ --zone=$ZONE --project=$PROJECT_ID

# Set proper permissions for nginx
gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 755 /var/www/html"

# Update nginx configuration if VM already existed
if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --format='get(status)' | grep -q "RUNNING"; then
    echo "Installing and starting nginx..."
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo apt-get update -y && sudo apt-get install -y nginx && sudo systemctl start nginx && sudo systemctl enable nginx"
    
    echo "Configuring nginx..."
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo tee /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;

    # Handle static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control \"public, immutable\";
    }

    # Dashboard Module - serve from /dashboard path
    location /dashboard/ {
        root /var/www/html;
        try_files \$uri \$uri/ /dashboard/index.html;
    }


    # Root redirect to dashboard
    location = / {
        return 301 /dashboard/;
    }

    # Health check
    location /health {
        access_log off;
        add_header Content-Type text/html;
        return 200 '<!DOCTYPE html><html><head><title>Dashboard Module - Healthy</title></head><body><h1>Dashboard Module - Healthy</h1><p>Status: OK</p></body></html>';
    }

    # Security headers
    add_header X-Frame-Options \"SAMEORIGIN\" always;
    add_header X-Content-Type-Options \"nosniff\" always;
    add_header X-XSS-Protection \"1; mode=block\" always;
    add_header Referrer-Policy \"strict-origin-when-cross-origin\" always;
}
EOF"
    
    echo "Testing and reloading nginx..."
    gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --command="sudo nginx -t && sudo systemctl reload nginx"
fi

echo -e "${GREEN}✅ Dashboard Module deployed successfully${NC}"

# Step 6: Get external IP
echo -e "${YELLOW}🌐 Step 6: Getting external IP...${NC}"
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Final status
echo ""
echo -e "${GREEN}🎉 Dashboard Module deployed successfully!${NC}"
echo "============================================="
echo -e "${BLUE}📋 Deployment Details:${NC}"
echo "  • VM Instance: $INSTANCE_NAME"
echo "  • Zone: $ZONE"
echo "  • External IP: $EXTERNAL_IP"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "  • Dashboard Module: http://$EXTERNAL_IP/dashboard/"
echo "  • Health Check: http://$EXTERNAL_IP/health"
echo "  • Root (redirects to dashboard): http://$EXTERNAL_IP"
echo ""
echo -e "${BLUE}🔧 Management:${NC}"
echo "  • SSH: gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
echo "  • Nginx Logs: sudo tail -f /var/log/nginx/access.log"
echo "  • Delete: gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE"
echo ""
echo -e "${GREEN}✅ Dashboard Module is ready to use!${NC}"
