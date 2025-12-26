# FastAPI CI/CD Pipeline

A learning project demonstrating a complete CI/CD pipeline for a FastAPI application deployed on AWS EC2 using Jenkins and Docker.

## Overview

This project was built as a hands-on learning experience to understand modern DevOps practices. It showcases automated building, testing, and deployment of a simple FastAPI application.

## What I Built

### Application
- A simple FastAPI REST API with two endpoints
- Dockerized application using Python 3.11 and UV package manager
- Automated unit tests using pytest

### CI/CD Pipeline
- Jenkins server running on AWS EC2
- Automated builds triggered by Git pushes
- Automated testing before deployment
- Docker-based deployment
- Health check verification
- Automatic cleanup of old Docker images

## Architecture

### High-Level Overview

```
┌─────────────┐       push      ┌──────────────────────────────────────────────┐      ┌─────────────────────┐
│             │ ────────────────>│                                              │      │                     │
│    Code     │                  │              GitHub                          │      │  Available to User  │
│             │                  │                                              │      │                     │
└─────────────┘                  └──────────┬───────────────────────────────────┘      └─────────────────────┘
                                            │                                                      ▲
                                            │ build, test, deploy                                 │
                                            │                                                      │
                                            ▼                                                      │
                                 ┌──────────────────────────────────────────────┐                │
                                 │        AWS EC2 (Deployed)                    │ ───────────────┘
                                 │                                              │
                                 │  ┌─────────────────────────────────────┐    │
                                 │  │ Jenkins CI/CD Pipeline              │    │
                                 │  │  - Build Docker Image               │    │
                                 │  │  - Run Tests                        │    │
                                 │  │  - Deploy Container                 │    │
                                 │  │  - Health Check                     │    │
                                 │  └─────────────────────────────────────┘    │
                                 │                                              │
                                 │  ┌─────────────────────────────────────┐    │
                                 │  │ FastAPI Application (Port 8000)     │    │
                                 │  └─────────────────────────────────────┘    │
                                 │                                              │
                                 └──────────────────────────────────────────────┘
```

### Detailed Pipeline Flow

```
Developer Laptop                    AWS EC2 Instance
    |                                      |
    | 1. Code Push                         |
    +----> GitHub Repository               |
                |                          |
                | 2. Webhook/Poll          |
                +--------> Jenkins --------+
                              |            |
                              | 3. Build   |
                              v            |
                         Docker Image      |
                              |            |
                              | 4. Test    |
                              v            |
                         Run Tests         |
                              |            |
                              | 5. Deploy  |
                              v            |
                         FastAPI App       |
                         (Port 8000)       |
```

## Technology Stack

- **Application**: FastAPI, Python 3.11
- **Package Manager**: UV
- **Containerization**: Docker
- **CI/CD**: Jenkins
- **Testing**: Pytest
- **Cloud**: AWS EC2
- **Version Control**: Git, GitHub

## Pipeline Stages

1. **Checkout**: Pull latest code from GitHub
2. **Build**: Create Docker image with application code
3. **Test**: Run automated unit tests inside container
4. **Deploy**: Stop old container and start new one
5. **Health Check**: Verify application is running correctly
6. **Cleanup**: Remove old Docker images to save space

## Learning Journey

### Phase 1: Basic Setup
- Created simple FastAPI application
- Set up AWS EC2 instance
- Installed Docker on EC2

### Phase 2: Jenkins Configuration
- Installed Jenkins in Docker container
- Configured Docker-in-Docker access
- Created first Jenkins pipeline job

### Phase 3: Pipeline Development
- Wrote Jenkinsfile for automated builds
- Configured GitHub integration
- Set up automated triggers

### Phase 4: Testing & Deployment
- Added pytest for automated testing
- Implemented health checks
- Configured proper deployment process

## Challenges Faced

1. **Docker Permissions**: Jenkins container needed special permissions to access Docker socket
2. **Network Isolation**: Health checks couldn't reach containers via localhost
3. **Security Groups**: Had to configure AWS firewall rules for ports 8080 and 8000
4. **Shell Syntax**: Different shell syntax requirements in Jenkins pipeline

## API Endpoints

- `GET /` - Returns welcome message
- `GET /shahryar` - Returns custom endpoint response

## Running Locally

```bash
# Install dependencies
uv sync

# Run the application
uv run uvicorn main:app --reload

# Run tests
uv run pytest -v
```

## Deployment Process

1. Make changes to code
2. Commit and push to GitHub
3. Jenkins automatically detects changes
4. Pipeline builds Docker image
5. Tests run automatically
6. If tests pass, application deploys
7. Health check verifies deployment
8. Application is live

## Future Improvements

- Add staging environment
- Implement blue-green deployment
- Add monitoring and alerting
- Set up HTTPS with SSL certificate
- Add database integration
- Implement proper logging
- Add security scanning
- Create infrastructure as code with Terraform

## What I Learned

- How to containerize applications with Docker
- Setting up and configuring Jenkins
- Writing declarative Jenkins pipelines
- Docker-in-Docker concepts
- AWS EC2 and security group management
- Automated testing in CI/CD
- Git workflow for continuous deployment
- Troubleshooting deployment issues

## Project Structure

```
cicd/
├── main.py                 # FastAPI application
├── test_main.py           # Unit tests
├── Dockerfile             # Docker configuration
├── Jenkinsfile            # Jenkins pipeline definition
├── pyproject.toml         # Python dependencies
├── uv.lock               # Locked dependencies
├── docker-compose.yml    # Docker Compose config
├── ec2-setup.sh          # EC2 setup script
└── README.md             # This file
```

## Access

- Application: http://34.233.71.49:8000
- Jenkins: http://34.233.71.49:8080

## Notes

This is a learning project and should not be used in production without additional security hardening, proper secret management, and infrastructure improvements.

## Author

Shahryar - Learning DevOps and Cloud Engineering

## Acknowledgments

This project was built as part of my journey to understand DevOps practices and modern deployment workflows.
