# See README for instructions. Requires sagemaker>=2.x and proper IAM role.
import os, boto3
from sagemaker.workflow.parameters import ParameterString
from sagemaker.workflow.steps import ProcessingStep, TrainingStep, CacheConfig
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.model_step import RegisterModel
from sagemaker.sklearn.processing import SKLearnProcessor
from sagemaker.estimator import Estimator
from sagemaker import image_uris

region = os.getenv("AWS_REGION","me-central-1")
role = os.environ["SAGEMAKER_EXEC_ROLE"]
bucket = os.environ.get("SM_OUTPUT_BUCKET","your-bucket")

cache = CacheConfig(enable_caching=True, expire_after="30d")
xgb_img = image_uris.retrieve(framework="xgboost", region=region, version="1.7-1")

proc = SKLearnProcessor(framework_version="1.4-1", role=role, instance_type="ml.m5.xlarge", instance_count=1)
step_process = ProcessingStep(
    name="BuildFeatures",
    processor=proc,
    code="processors/build_features.py",
    outputs=[
        {"OutputName":"train", "S3Output":{"S3Uri": f"s3://{bucket}/aif/train/", "LocalPath":"/opt/ml/processing/output/train"}}
    ],
    cache_config=cache
)

est = Estimator(image_uri=xgb_img, role=role, instance_type="ml.m5.xlarge", instance_count=1,
                output_path=f"s3://{bucket}/aif/model/")
est.set_hyperparameters(objective="binary:logistic", num_round=50, max_depth=5)

step_train = TrainingStep(
    name="TrainModel",
    estimator=est,
    inputs={"train": step_process.properties.ProcessingOutputConfig.Outputs["train"].S3Output.S3Uri},
    cache_config=cache
)

register = RegisterModel(
    name="RegisterModel",
    estimator=est,
    model_data=step_train.properties.ModelArtifacts.S3ModelArtifacts,
    content_types=["text/csv"], response_types=["application/json"],
    inference_instances=["ml.m5.large"], transform_instances=["ml.m5.large"],
    model_package_group_name="ahla-aif-models", approval_status="PendingManualApproval"
)

def create_pipeline():
    return Pipeline(
        name="Ahla-AIF-Pipeline",
        steps=[step_process, step_train, register]
    )

if __name__ == "__main__":
    print(create_pipeline().definition())
