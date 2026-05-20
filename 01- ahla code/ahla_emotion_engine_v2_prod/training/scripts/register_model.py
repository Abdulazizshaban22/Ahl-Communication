import mlflow
client = mlflow.MlflowClient()
# Transition last version to Staging (example)
name = "ahla-emotion"
for mv in client.search_model_versions(f"name='{name}'"):
    last = mv
    break
# Placeholder: real criteria should be metric-based gates
# client.transition_model_version_stage(name=name, version=last.version, stage="Staging")
print("Model registration placeholder complete")
