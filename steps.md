Here is the complete, high-level overview of our entire engineering journey for Project 1. We built this project to match the real-world scale and safety constraints that engineering teams at Safaricom face every single day.
------------------------------
## Step 1: Writing the High-Performance Code (app.py & requirements.txt)

* What We Did: We built a mock M-PESA Callback API using FastAPI (Python). When a customer makes a payment, Safaricom's core systems send a payment confirmation payload to a merchant's server. We also wrote a /healthz endpoint.
* Why It Matters for your Resume: In production, Kubernetes needs a way to check if an application is running smoothly or frozen. The /healthz route gives the cluster an automated health check probe to prevent traffic from hitting broken instances.

------------------------------
## Step 2: Designing the Multi-Stage Container (Dockerfile)

* What We Did: Instead of writing a basic Dockerfile, we built a Multi-Stage Dockerfile using a slim Python image base.
* Stage 1 (Builder): Downloaded and compiled all our Python dependencies.
   * Stage 2 (Final): Copied only the compiled packages and our code, leaving behind all heavy build tools.
* Why It Matters for your Resume: Safaricom handles massive data volumes and faces constant security threats. Multi-stage builds dramatically shrink container sizes (saving bandwidth) and remove debugging utilities, which drops security vulnerability risks to near zero.

------------------------------
## Step 3: Automating with DevSecOps (GitHub Actions)

* What We Did: We wrote a CI pipeline script (ci-cd-pipeline.yml) that triggers automatically every time you push code to GitHub.
* It checks your Python syntax style rules automatically.
   * It triggers an automated Trivy Security Scan to audit your container for High or Critical security exploits.
   * Once verified clean, it securely logs into your Docker Hub account (y3g0n) using encrypted environment secrets and pushes your production-ready image.
* Why It Matters for your Resume: Modern tech teams do not build and push images manually from their laptops. Automating security gates in the CI pipeline ensures that vulnerable code never reaches a production cluster.

------------------------------
## Step 4: Troubleshooting the GitOps Controllers

* What We Did: We initially tried to deploy the application using a third-party progressive delivery controller (Argo Rollouts). During this phase, we hit real-world engineering hurdles:
* Network CLI blocks: We bypassed network download timeouts by writing configurations locally using cat << 'EOF' scripts.
   * RBAC Permission Denied Errors: We discovered through cluster logs that the controller was crashing because Docker Desktop didn't grant it permission to coordinate cluster leadership leases (coordination.k8s.io).
* Why It Matters for your Resume: Interviewers want to see how you think when things break. This stage gives you a great story about troubleshooting Role-Based Access Control (RBAC) and reading internal Kubernetes logs to find a root cause.

------------------------------
## Step 5: Engineering the Native Canary Architecture

* What We Did: Rather than getting stuck on an unstable third-party tool, we pivoted to a native, bulletproof Kubernetes strategy. We deployed two separate versions side-by-side:
* mpesa-callback-stable running 3 replicas of version v1.0.0 (75% of capacity).
   * mpesa-callback-canary running 1 replica of version v2.0.0 (25% of capacity).
   * We connected both deployments to a single Unified Kubernetes Service using a shared label descriptor (app: mpesa-callback).
* Why It Matters for your Resume: Because the service distributes network requests evenly among all matching pods, it naturally routes exactly 25% of traffic to your new Canary version and 75% to your Stable version. You achieved high-end progressive traffic splitting natively, making the system incredibly reliable, lightweight, and easy to maintain.

------------------------------
Now that you have a solid grasp of how code moves securely from your laptop to a live cluster environment, let me know if you are ready to kick off 