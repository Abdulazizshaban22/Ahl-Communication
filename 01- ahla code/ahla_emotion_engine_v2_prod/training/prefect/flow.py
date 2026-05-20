from prefect import flow, task
import os, datetime as dt, subprocess, json

@task(retries=2, retry_delay_seconds=60)
def extract_new_data():
    # placeholder: pull approved labeled data from Label Studio export
    path = os.getenv("LABELED_PATH","data/labeled.jsonl")
    assert os.path.exists(path), "No labeled data found"
    return path

@task
def train_model(data_path: str):
    # placeholder: run python training script which logs to MLflow
    subprocess.check_call(["python","training/scripts/train.py", data_path])
    return "ok"

@task
def evaluate_and_register():
    subprocess.check_call(["python","training/scripts/register_model.py"])

@flow(name="ahla-emotion-autotrain")
def autotrain():
    dp = extract_new_data()
    train_model(dp)
    evaluate_and_register()

if __name__ == "__main__":
    autotrain()
