import os, boto3, json
from botocore.config import Config

region = os.getenv("AWS_REGION", "eu-central-1")
endpoint = os.environ["AIF_SAGEMAKER_ENDPOINT"]  # e.g., ahla-aif-rt
smr = boto3.client("sagemaker-runtime", region_name=region, config=Config(retries={'max_attempts': 3}))

def predict(payload: dict) -> dict:
    resp = smr.invoke_endpoint(
        EndpointName=endpoint,
        ContentType="application/json",
        Body=json.dumps(payload).encode("utf-8")
    )
    return json.loads(resp["Body"].read().decode("utf-8"))
