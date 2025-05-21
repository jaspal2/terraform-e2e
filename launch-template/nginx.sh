#!/bin/bash

# Update the system
echo "Updating system packages..."
yum update -y || apt-get update -y

# Determine the OS
if [ -f /etc/redhat-release ]; then
    # For Amazon Linux, RHEL, or CentOS
    echo "Detected Red Hat based system"
    
    # Install nginx
    echo "Installing nginx..."
    amazon-linux-extras install -y nginx1 2>/dev/null || yum install -y nginx
    
    # Start and enable nginx
    echo "Starting and enabling nginx service..."
    systemctl start nginx
    systemctl enable nginx
    
    # Configure firewall if it's active
    if systemctl is-active --quiet firewalld; then
        echo "Opening port 80 in firewall..."
        firewall-cmd --permanent --add-service=http
        firewall-cmd --reload
    fi
    
elif [ -f /etc/debian_version ]; then
    # For Ubuntu or Debian
    echo "Detected Debian based system"
    
    # Install nginx
    echo "Installing nginx..."
    apt-get install -y nginx
    
    # Start and enable nginx
    echo "Starting and enabling nginx service..."
    systemctl start nginx
    systemctl enable nginx
    
    # Configure firewall if it's active
    if command -v ufw > /dev/null; then
        echo "Opening port 80 in firewall..."
        ufw allow 'Nginx HTTP'
    fi
else
    echo "Unsupported operating system"
    exit 1
fi

# Create a custom index page with instance metadata
echo "Creating custom index page..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PUBLIC_IPV4=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create a simple HTML page with instance information
cat > /usr/share/nginx/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Nginx Server - AWS EC2</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 {
            color: #232f3e;
            border-bottom: 2px solid #ff9900;
            padding-bottom: 10px;
        }
        .info {
            background-color: #f8f8f8;
            border-left: 5px solid #ff9900;
            padding: 15px;
            margin: 20px 0;
        }
        .success {
            color: #2e8b57;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>Welcome to Nginx on AWS EC2</h1>
    <p class="success">✅ Nginx has been successfully installed and configured!</p>
    
    <div class="info">
        <h2>Instance Information:</h2>
        <ul>
            <li><strong>Instance ID:</strong> ${INSTANCE_ID}</li>
            <li><strong>Availability Zone:</strong> ${AVAILABILITY_ZONE}</li>
            <li><strong>Public IP:</strong> ${PUBLIC_IPV4}</li>
        </ul>
    </div>
    
    <p>This page was generated automatically by the EC2 launch template user data script.</p>
</body>
</html>
EOF

# Check if nginx is running
echo "Verifying nginx is running..."
if systemctl is-active --quiet nginx; then
    echo "Nginx installation completed successfully!"
else
    echo "Nginx installation failed or service not running."
    exit 1
fi