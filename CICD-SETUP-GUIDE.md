# CI/CD Setup Guide - Learn by Doing

This guide will help you set up Jenkins CI/CD pipeline for your FastAPI application on AWS EC2.

## Prerequisites
- AWS EC2 instance running
- `cicd.pem` file in your Downloads folder
- Git Bash installed on your laptop

---

## Step 1: Connect to Your EC2 Instance

### 1.1 Set correct permissions for your PEM file
Open Git Bash and run:
```bash
cd ~/Downloads
chmod 400 cicd.pem
```

### 1.2 Connect to EC2
Replace `YOUR_EC2_IP` with your actual EC2 public IP address:
```bash
ssh -i ~/Downloads/cicd.pem ec2-user@YOUR_EC2_IP
```

**Note:** If you're using Ubuntu AMI, use `ubuntu` instead of `ec2-user`

---

## Step 2: Install Docker on EC2

Once connected to your EC2 instance, run these commands:

```bash
# Update system
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in for changes to take effect
exit
```

### 2.1 Reconnect and verify Docker
```bash
ssh -i ~/Downloads/cicd.pem ec2-user@YOUR_EC2_IP

# Test Docker
docker run hello-world
```

If you see "Hello from Docker!", you're good to go!

---

## Step 3: Install Jenkins on Your Laptop (Windows)

### 3.1 Install Java (Jenkins requirement)
1. Download Java JDK 17 or 21 from: https://adoptium.net/
2. Install it with default settings
3. Verify installation in Git Bash:
```bash
java -version
```

### 3.2 Install Jenkins
1. Download Jenkins from: https://www.jenkins.io/download/
2. Choose "Windows" installer
3. Install with default settings
4. Jenkins will start automatically and open in browser at: http://localhost:8080

### 3.3 Unlock Jenkins
1. Find the initial admin password. In Git Bash:
```bash
cat /c/ProgramData/Jenkins/.jenkins/secrets/initialAdminPassword
```
2. Copy the password and paste it in the browser
3. Click "Install suggested plugins"
4. Create your first admin user

---

## Step 4: Install Docker on Your Laptop (for Jenkins to build images)

### 4.1 Install Docker Desktop
1. Download from: https://www.docker.com/products/docker-desktop
2. Install and restart your computer
3. Open Docker Desktop and make sure it's running

### 4.2 Verify Docker
In Git Bash:
```bash
docker --version
docker ps
```

---

## Step 5: Configure Jenkins

### 5.1 Install Required Jenkins Plugins
1. Go to Jenkins Dashboard → Manage Jenkins → Plugins
2. Click "Available plugins"
3. Search and install these plugins:
   - Docker Pipeline
   - SSH Agent
   - Git plugin (should already be installed)
4. Restart Jenkins when prompted

### 5.2 Add Your EC2 SSH Key to Jenkins
1. Go to: Dashboard → Manage Jenkins → Credentials
2. Click "(global)" → "Add Credentials"
3. Fill in:
   - Kind: **SSH Username with private key**
   - ID: `ec2-ssh-key`
   - Username: `ec2-user`
   - Private Key: Click "Enter directly" → Click "Add"
   - Open your `cicd.pem` file in notepad and copy entire content
   - Paste it in the Key field
4. Click "Create"

### 5.3 Add EC2 Host as Environment Variable
1. Go to: Dashboard → Manage Jenkins → System
2. Scroll to "Global properties"
3. Check "Environment variables"
4. Click "Add"
   - Name: `EC2_HOST`
   - Value: `YOUR_EC2_PUBLIC_IP`
5. Click "Save"

---

## Step 6: Create Jenkins Pipeline Job

### 6.1 Create New Job
1. Click "New Item" on Jenkins Dashboard
2. Enter name: `fastapi-cicd`
3. Select "Pipeline"
4. Click "OK"

### 6.2 Configure the Pipeline
1. Scroll to "Pipeline" section
2. Definition: Select "Pipeline script from SCM"
3. SCM: Select "Git"
4. Repository URL: Enter your GitHub repo URL
   - Example: `https://github.com/yourusername/cicd.git`
5. Credentials: Add your GitHub credentials if repo is private
6. Branch: `*/main`
7. Script Path: `Jenkinsfile`
8. Click "Save"

---

## Step 7: Push Your Code to GitHub

On your laptop, in Git Bash:

```bash
cd /c/projects/cicd

# Make sure all files are added
git status

# Add the new files
git add Dockerfile Jenkinsfile docker-compose.yml ec2-setup.sh

# Commit
git commit -m "Add CI/CD configuration files"

# Push to GitHub (create repo first on GitHub if you haven't)
git remote add origin https://github.com/yourusername/cicd.git
git push -u origin main
```

---

## Step 8: Configure EC2 Security Group

Your EC2 needs to allow incoming traffic:

1. Go to AWS Console → EC2 → Security Groups
2. Select your EC2's security group
3. Click "Edit inbound rules"
4. Add these rules:
   - Type: **SSH**, Port: **22**, Source: **Your laptop IP** (for SSH access)
   - Type: **Custom TCP**, Port: **8000**, Source: **0.0.0.0/0** (for FastAPI)
5. Click "Save rules"

---

## Step 9: Run Your First Build!

### 9.1 Trigger the Pipeline
1. Go to Jenkins Dashboard → Click on your job `fastapi-cicd`
2. Click "Build Now"
3. Watch the build progress in "Build History"
4. Click on the build number (e.g., #1) to see details
5. Click "Console Output" to see what's happening

### 9.2 What Jenkins Will Do:
1. ✅ Checkout your code from GitHub
2. ✅ Build Docker image on your laptop
3. ✅ Test the app
4. ✅ Copy image to EC2
5. ✅ Deploy and run on EC2
6. ✅ Health check

---

## Step 10: Verify Deployment

### 10.1 Check if app is running on EC2
```bash
ssh -i ~/Downloads/cicd.pem ec2-user@YOUR_EC2_IP

# Check running containers
docker ps

# You should see your fastapi-app container running
```

### 10.2 Test the application
In your browser, visit:
```
http://YOUR_EC2_PUBLIC_IP:8000
```

You should see: `{"messag":"this is cicd"}`

---

## Step 11: Making Changes and Auto-Deploy

Now whenever you make changes:

1. Edit your code (e.g., change the message in `main.py`)
2. Commit and push:
```bash
git add .
git commit -m "Update message"
git push
```
3. Go to Jenkins and click "Build Now"
4. Jenkins will automatically build, test, and deploy!

---

## Troubleshooting

### Problem: Can't connect to EC2
- Check security group allows SSH (port 22) from your IP
- Verify PEM file permissions: `ls -la ~/Downloads/cicd.pem` (should be -r--------)
- Verify EC2 public IP hasn't changed (elastic IP recommended)

### Problem: Docker command not found in Jenkins
- Make sure Docker Desktop is running on your laptop
- Restart Jenkins: http://localhost:8080/restart

### Problem: SSH key doesn't work in Jenkins
- Verify the credential ID in Jenkinsfile matches: `ec2-ssh-key`
- Check the entire PEM file content was copied (including BEGIN/END lines)

### Problem: Build fails at deployment stage
- SSH to EC2 and check: `docker ps -a`
- Check EC2 has enough disk space: `df -h`
- Check logs on EC2: `docker logs fastapi-app`

---

## Next Steps to Learn More

1. **Add tests**: Create a test file and add a proper test stage
2. **Use webhooks**: Auto-trigger builds when you push to GitHub
3. **Add environment variables**: Store secrets securely in Jenkins
4. **Set up monitoring**: Add health check endpoints
5. **Use Docker Hub**: Push images to registry instead of SCP
6. **Add staging environment**: Deploy to test server first

---

## Useful Commands

### On your laptop:
```bash
# View running containers
docker ps

# Build image locally to test
docker build -t fastapi-cicd .

# Run locally
docker run -p 8000:8000 fastapi-cicd

# Test locally
curl http://localhost:8000
```

### On EC2:
```bash
# View logs
docker logs fastapi-app

# Follow logs in real-time
docker logs -f fastapi-app

# Stop app
docker stop fastapi-app

# Start app
docker start fastapi-app

# Remove app
docker rm -f fastapi-app

# View all images
docker images
```

---

## Summary

You now have a complete CI/CD pipeline where:
1. You write code on your laptop
2. Push to GitHub
3. Jenkins builds Docker image
4. Jenkins deploys to EC2
5. Your app runs on EC2 accessible from anywhere!

Good luck with your learning journey! 🚀
