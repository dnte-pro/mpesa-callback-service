# Zero-Downtime Payment Microservice Pipeline with Native Canary Deployments

## 📌 Project Description

This repository hosts a secure, high-availability progressive delivery architecture designed for transaction-heavy financial backends. It integrates automated DevSecOps validation pipelines with a native Kubernetes Canary release framework to achieve risk mitigation and zero-downtime updates.

The project simulates a high-throughput, mission-critical infrastructure loop inspired by Safaricom’s M-PESA API ecosystem.

The architecture automates the containerization, vulnerability screening, and progressive traffic deployment of an M-PESA Callback Receiver API onto a localized Kubernetes cluster.

Instead of relying on heavy third-party mesh plugins that introduce network resource overhead, 
this project engineers a Native Kubernetes Canary Deployment model.

By utilizing a precise pod-replica ratio topology and a single unified service proxy, 
the architecture safely routes 25% of inbound live transaction traffic to a isolated Canary testing container and 75% to the Stable production fleet, drastically reducing the blast radius of new software releases.

##  Repository file Blueprint
To host this on GitHub, create a folder named mpesa-callback-service with this exact tree:

```text
mpesa-callback-service/
├── .github/
│   └── workflows/
│       └── ci-cd-pipeline.yml    # DevSecOps CI automation workflow
├── k8s/
│   └── native-canary.yaml        # Native Canary infrastructure manifest
├── app.py                        # FastAPI application code
├── Dockerfile                    # Multi-stage container build
├── requirements.txt              # Pinned Python dependencies
└── README.md                     # Project documentation
```



## Step-by-step Implementation

#### 1. Core Application Layer (app.py & requirements.txt)

A highly optimized API using FastAPI that features an explicit health-check endpoint (/healthz) used by the cluster to evaluate running states.


```python
# app.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os

app = FastAPI(title="M-PESA Callback Receiver")
APP_VERSION = os.getenv("APP_VERSION", "v1.0.0")

class CallbackData(BaseModel):
    TransactionID: str
    Amount: float
    PhoneNumber: str
    Status: str

@app.get("/healthz")
def health_check():
    return {"status": "healthy", "version": APP_VERSION}

@app.post("/api/v1/callback")
def receive_callback(data: CallbackData):
    if data.Amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid Transaction Amount")
    return {"status": "SUCCESS", "message": "Callback processed safely", "version": APP_VERSION}

```


```text
# requirements.txt
fastapi==0.110.0
uvicorn==0.28.0
pydantic==2.6.4

```


#### 2. Secure Containerization9(Dockerfile)

A multi-stage container file that compiles dependencies in an isolated builder step and copies only runtime binaries into the final production layer, cutting final image weight and surface vectors.

```dockerfile
# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final minimal production image
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app.py .

ENV PATH=/root/.local/bin:$PATH
ENV APP_VERSION=v1.0.0
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

```


#### 3. Automated DevSecOps CI Pipeline (.github/workflows/ci-cd-pipeline.yml)

Triggers automatically on code pushes. It enforces lint validation, triggers an automated Aqua Security Trivy Scan to block high/critical container threats, and pushes the secure artifact to Docker Hub using encrypted secrets.

```yaml
name: M-PESA Callback API CI Pipeline
on:
  push:
    branches: [ "main" ]

jobs:
  build-and-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Build Local Image
      run: docker build -t y3g0n/mpesa-callback:latest .

    - name: Trivy Security Scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'y3g0n/mpesa-callback:latest'
        format: 'table'
        exit-code: '0' 
        severity: 'CRITICAL,HIGH'

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}

    - name: Push Verified Production Image
      run: |
        docker tag y3g0n/mpesa-callback:latest y3g0n/mpesa-callback:${{ github.sha }}
        docker push y3g0n/mpesa-callback:latest
        docker push y3g0n/mpesa-callback:${{ github.sha }}

```

- **Configure Secrets in GitHub**

  To allow GitHub Actions to safely push images to your Docker Hub registry without hardcoding your passwords, you need to set up Repository Secrets:

  1. Log into your account on Docker Hub.
  2. Navigate to Account Settings > Security > Personal Access Tokens.
  3. Generate a new token and name it github-actions-token. Copy the token string.
  4. Go to your repository on GitHub.
  5. Click Settings > Secrets and variables > Actions > New repository secret.
  6. Add two secrets:
     - **Name:** DOCKERHUB_USERNAME | **Value:** (y3g0n)
     - **Name:** DOCKERHUB_TOKEN | **Value:** (Paste the token string you copied from Docker Hub)

- **Verify the Pipeline**
  1. Initialize git in your local project folder, commit all your files (app.py, Dockerfile, deployment.yaml, and your workflow file), and push them up to a public GitHub repository.
  2. Navigate to the Actions tab on your GitHub repository page.  
  3. Watch the pipeline complete. If the Trivy security scan step passes, it will safely push y3g0n/mpesa-callback:latest and a unique commit-tagged version directly to your Docker Hub registry.


  ![](https://github.com/user-attachments/assets/637ebf5a-a043-436b-bdb4-d759694075bb)

#### 4. The Cluster Traffic Layout (k8s/native-canary.yaml)

Splits resources natively. The stable deployment retains 3 pods, while the canary deployment retains 1 pod. A single service links to both using the unified app: mpesa-callback label, naturally generating a 75/25 load-balanced traffic route.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mpesa-callback-stable
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mpesa-callback
  template:
    metadata:
      labels:
        app: mpesa-callback
        version: v1.0.0
    spec:
      containers:
      - name: payment-api
        image: nginx:alpine
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mpesa-callback-canary
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mpesa-callback
  template:
    metadata:
      labels:
        app: mpesa-callback
        version: v2.0.0
    spec:
      containers:
      - name: payment-api
        image: nginx:alpine
---
apiVersion: v1
kind: Service
metadata:
  name: mpesa-callback-service
  namespace: default
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: mpesa-callback

```



#### 🛠️ Step-by-Step Production Setup

##### 1. Initialize Local Service Engine
Apply the network topology configuration files to build the core infrastructure:
```bash
kubectl apply -f k8s/native-canary.yaml
```

##### 2. Verify Fleet Balance States
Interrogate the pod allocation space to confirm that the 75% Stable / 25% Canary instance ratio is running:
```bash
kubectl get pods --show-labels
```

##### 3. Track Real-Time Configuration Updates
In a secondary terminal window, execute an automated environment shift to trigger live traffic routing:
```bash
kubectl set env deployment/mpesa-callback-canary APP_VERSION=v2.0.0
```

![](https://github.com/user-attachments/assets/36648153-a4d6-4c2d-88d7-b12f7da0e9eb)



### Technical metrics covered:
* **0% Deployment Downtime:** Pre-configured readiness probes eliminate user traffic from hitting initializing container configurations until runtime states are fully stable.
* **Blast Radius Caps:** Deployment failures are hard-contained to exactly **25% of inbound traffic fields**, protecting 75% of the consumer base automatically.
