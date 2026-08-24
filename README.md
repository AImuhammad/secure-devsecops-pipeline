# Secure DevSecOps Pipeline

A production-oriented CI/CD pipeline demonstrating DevSecOps practices for a Python Flask application.

## Architecture

GitHub → Jenkins → Docker → SonarQube → Quality Gate → Trivy → Container Test → Docker Hub

## Application

The application is a lightweight Flask REST API with:

- Application information endpoint
- Health-check endpoint
- Environment-based configuration
- Automated unit tests

### Endpoints

`GET /`

Returns application information, version, environment, and status.

`GET /health`

Returns the application health status.

## DevSecOps Pipeline

The Jenkins pipeline performs:

1. Source code checkout from GitHub
2. Python application testing with pytest
3. Docker image build
4. Static code analysis with SonarQube
5. SonarQube quality gate validation
6. Container vulnerability scanning with Trivy
7. Runtime container health testing
8. Docker Hub image publishing

## Security

The pipeline blocks deployment when:

- Application tests fail
- SonarQube quality gate fails
- Trivy detects HIGH or CRITICAL vulnerabilities

## Docker

Build the image locally:

```bash
docker build -t secure-devsecops-app:5 .
