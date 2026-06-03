Enterprise GitOps Microservices Pipeline with Canary Deployments (M-PESA Callback Sandbox)Designed and containerized a high-performance FastAPI microservice using a multi-stage Docker configuration, optimizing final production image weight and security footprint.Built an automated DevSecOps CI Pipeline using GitHub Actions, integrating static syntax analysis and Trivy vulnerability scanning to block high/critical security threats before registry uploads.Implemented a continuous delivery model using GitOps principles to orchestrate advanced progressive delivery on local clusters.Structured a Canary Rollout workflow defining automated performance checks and precise traffic splitting (25% / 50% / 100%), successfully minimizing production deployment blast radius and risk.









Enterprise GitOps Microservices Pipeline with Canary Deployments📌 Project OverviewThis repository contains a production-grade, DevSecOps-driven deployment blueprint designed to mimic high-availability transaction architectures (such as the Safaricom M-PESA ecosystem). It automates the lifecycle of a secure M-PESA Callback API from code commit to progressive canary delivery on a Kubernetes cluster.By leveraging GitHub Actions for secure CI/CD gates and Argo Rollouts for declarative progressive deployment, this architecture eliminates manual deployment risks, reduces the application blast radius during software upgrades, and guarantees zero-downtime microservice operations.🏗️ System ArchitectureThe application runs through an automated transition lifecycle structured across three distinct environments:text [ Developer Workspace ] ──> Push Code ──> [ GitHub Actions (CI) ]
                                                   │
                                     ┌─────────────┴─────────────┐
                                     ▼                           ▼
                              [ Flake8 Linting ]        [ Trivy DevSecOps Scan ]
                                                                 │ (If Clean)
                                                                 ▼
 [ Kubernetes Cluster ] <── Automated Sync <─── [ Docker Hub (y3g0n/mpesa-callback) ]
           │
           ├──► [ Argo Rollouts Controller ] ──► Splits Live Inbound Traffic
           │
           ├──► [ 75% Stable Production Traffic ] ──► Pod v1.0.0
           └──► [ 25% Canary Testing Traffic ]    ──► Pod v2.0.0 (30s Automated Evaluation)
Use code with caution.🛠️ Core Technology StackApplication Framework: FastAPI (Python 3.11) with Pydantic payload validation.Containerization: Multi-stage scratch-optimized Docker builds.CI/CD Automation: GitHub Actions with secure encrypted repository secrets management.DevSecOps Security: Aqua Security Trivy container vulnerability scanner.Continuous Delivery: Argo Rollouts declarative GitOps progressive delivery framework.Target Cluster System: Docker Desktop Kubernetes runtime engine.📁 Repository Structuretextmpesa-callback-service/
├── .github/
│   └── workflows/
│       └── ci-cd-pipeline.yml   # DevSecOps CI Pipeline Automation
├── k8s/
│   ├── canary-rollout.yaml      # Argo Canary Traffic Split Definitions
│   └── argocd-app.yaml          # Declarative ArgoCD GitOps Engine
├── app.py                       # High-performance FastAPI Payment API Code
├── Dockerfile                   # Safe Multi-Stage Production Dockerfile
├── requirements.txt             # Declared Python Production Dependencies
└── README.md                    # Core System Architecture Documentation
Use code with caution.🚀 Execution & Deployment Guide1. Local Environment Pre-requisitesEnsure your workstation has the following engines activated and verified:bash# Verify cluster status
kubectl get nodes

# Ensure the core progressive delivery namespace is initialized
kubectl create namespace argo-rollouts
Use code with caution.2. Run Local Automation SetupDeploy the required core infrastructure resources straight to your running Kubernetes engine using the localized text blocks:bash# Apply the canary deployment specifications
kubectl apply -f k8s/canary-rollout.yaml
Use code with caution.3. Trigger & Monitor a Live Canary UpdateSimulate a production software transition by changing the version environment variables from v1.0.0 to v2.0.0 inside your cluster engine workspace:bash# Update runtime engine version parameters
kubectl set env rollout/mpesa-callback-rollout APP_VERSION=v2.0.0
Use code with caution.Track the progressive traffic split directly within your shell terminal windows to watch live, low-risk infrastructure scaling:bash# Track container switches in real-time
kubectl get pods -l app=mpesa-callback -w
Use code with caution.📈 Key Production Metrics DeliveredBlast Radius Reduction: Automated canary rules isolate software runtime failures to exactly 25% of inbound live production traffic.Zero-Downtime Guarantee: Pre-configured HTTP readiness probes block client requests from hitting newly initialized pods until the underlying system application is entirely healthy.Enhanced Container Security: Multi-stage image build optimization strips out dev packages, yielding a minimal surface area and dropping high/critical runtime vulnerabilities to zero.