from fastapi import FastAPI

app = FastAPI(
    title="Pet Rescue API",
    description="API para la gestion de mascotas extraviadas",
    version="0.1.0",
)


@app.get("/")
def read_root():
    return {
        "project": "Pet Rescue",
        "status": "running",
        "version": "0.1.0",
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok"
    }
