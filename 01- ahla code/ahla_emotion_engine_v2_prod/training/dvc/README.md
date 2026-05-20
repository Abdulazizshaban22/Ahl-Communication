Use DVC to version datasets and training outputs.
Commands:
  dvc init
  dvc add training/datasets/labeled.jsonl
  dvc remote add -d ahla s3://<bucket>/ahla-dvc
  dvc push
