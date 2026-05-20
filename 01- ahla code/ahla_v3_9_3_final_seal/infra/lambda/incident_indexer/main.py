import os, json, logging, base64, time
import urllib.parse, datetime
import boto3, requests

logger = logging.getLogger()
logger.setLevel(logging.INFO)

OPENSEARCH_ENDPOINT = os.environ.get("OPENSEARCH_ENDPOINT")
INDEX = os.environ.get("OPENSEARCH_INDEX", "ahla-incidents")
AUTH_MODE = os.environ.get("AUTH_MODE", "iam").lower()
BASIC_USER = os.environ.get("BASIC_USER")
BASIC_PASS = os.environ.get("BASIC_PASS")

def handler(event, context):
    if not OPENSEARCH_ENDPOINT:
        logger.warning("No OPENSEARCH_ENDPOINT set")
        return {"status":"disabled"}

    # SNS event records
    items = []
    for rec in event.get("Records", []):
        msg = json.loads(rec["Sns"]["Message"])
        items.append({
            "@timestamp": datetime.datetime.utcnow().isoformat()+"Z",
            "alarm_name": msg.get("AlarmName"),
            "state": msg.get("NewStateValue"),
            "reason": msg.get("NewStateReason"),
            "region": msg.get("Region"),
            "service": msg.get("Trigger", {}).get("Namespace"),
            "raw": msg
        })

    if not items:
        return {"status":"no_records"}

    # bulk index
    bulk = ""
    for it in items:
        bulk += json.dumps({ "index": { "_index": INDEX }}) + "
"
        bulk += json.dumps(it) + "
"

    url = f"{OPENSEARCH_ENDPOINT}/_bulk"
    headers = {"Content-Type":"application/x-ndjson"}

    if AUTH_MODE == "basic" and BASIC_USER:
        r = requests.post(url, data=bulk, headers=headers, auth=(BASIC_USER, BASIC_PASS), timeout=10)
    else:
        # For IAM-signed (needs SigV4 - kept simple for demo; recommend using requests-aws4auth in production)
        r = requests.post(url, data=bulk, headers=headers, timeout=10)
    logger.info("bulk status %s", r.status_code)
    return {"status": r.status_code}
