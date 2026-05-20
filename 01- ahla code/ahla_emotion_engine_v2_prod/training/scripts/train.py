import sys, json, os, time
import mlflow

def main(path):
    mlflow.set_experiment("ahla-emotion")
    with mlflow.start_run(run_name="train-"+str(int(time.time()))):
        # Placeholder: log params/metrics/artifacts
        mlflow.log_param("data_path", path)
        mlflow.log_metric("f1_macro", 0.78)  # dummy metric
        # Save dummy model artifact
        os.makedirs("model", exist_ok=True)
        open("model/README.txt","w").write("Placeholder model files")
        mlflow.log_artifacts("model", artifact_path="model")
        mlflow.sklearn.log_model(sk_model=None, artifact_path="model_sklearn", registered_model_name="ahla-emotion")
if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv)>1 else "data/labeled.jsonl")
