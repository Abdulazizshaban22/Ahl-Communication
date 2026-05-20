# Simplified sample — for production, prefer AWS-provided rotation templates.
# This stub documents the 4-step rotation workflow Secrets Manager expects.
import boto3, json, os, logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets = boto3.client('secretsmanager')
rds = boto3.client('rds')

def lambda_handler(event, context):
    step = event.get('Step')
    arn  = event['SecretId']
    token = event['ClientRequestToken']
    logger.info(f"Rotation step={step} secret={arn}")
    if step == "createSecret":
        _create(arn, token)
    elif step == "setSecret":
        _set(arn, token)
    elif step == "testSecret":
        _test(arn, token)
    elif step == "finishSecret":
        _finish(arn, token)
    else:
        raise ValueError("Unknown step")

def _get_current_json(arn):
    v = secrets.get_secret_value(SecretId=arn)
    return json.loads(v['SecretString'])

def _create(arn, token):
    curr = _get_current_json(arn)
    new = dict(curr)
    new['password'] = curr['password'] + "_r"  # TODO: generate strong password
    secrets.put_secret_value(SecretId=arn, ClientRequestToken=token, SecretString=json.dumps(new), VersionStages=['AWSPENDING'])
    logger.info("Created pending version")

def _set(arn, token):
    # Connect to the DB and set the password using AWSPENDING creds
    # (left as implementation detail — depends on engine: postgres/mysql/etc.)
    logger.info("Set password in DB — implement per engine")
    pass

def _test(arn, token):
    # Attempt a login with AWSPENDING creds
    logger.info("Test pending secret — implement DB connectivity test")
    pass

def _finish(arn, token):
    secrets.update_secret_version_stage(SecretId=arn, VersionStage='AWSCURRENT', MoveToVersionId=token, RemoveFromVersionId=None)
    logger.info("Promoted AWSCURRENT")
