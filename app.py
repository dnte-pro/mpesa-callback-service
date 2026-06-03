from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os

app = FastAPI(title="M-PESA Callback Receiver")

# Read the application version from environment variables (Critical for Canary deployment)
APP_VERSION = os.getenv("APP_VERSION", "v1.0.0")

class CallbackData(BaseModel):
    TransactionID: str
    Amount: float
    PhoneNumber: str
    Status: str

@app.get("/healthz")
def health_check():
    # Kubernetes will use this endpoint to monitor app health
    return {"status": "healthy", "version": APP_VERSION}

@app.post("/api/v1/callback")
def receive_callback(data: CallbackData):
    if data.Amount <= 0:
        raise HTTPException(status_code=400, detail="Invalid Transaction Amount")
    
    print(f"[{APP_VERSION}] Processed payment {data.TransactionID} of KES {data.Amount} from {data.PhoneNumber}")
    return {"status": "SUCCESS", "message": "Callback processed safely"}
