# SageMaker Pipeline skeleton (define: preprocess -> train -> evaluate -> register -> deploy)
# Run from a SageMaker Studio or CI with sagemaker==>=2.x and boto3 installed.
import os
import boto3
from sagemaker.workflow.parameters import ParameterString, ParameterInteger
from sagemaker.workflow.steps import ProcessingStep, TrainingStep, CacheConfig
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.properties import PropertyFile
from sagemaker.workflow.model_step import RegisterModel
from sagemaker import image_uris

region = os.getenv("AWS_REGION", "eu-central-1")
role = os.environ["SAGEMAKER_EXEC_ROLE"]
sess = boto3.Session(region_name=region)

# Parameters
p_model_group = ParameterString(name="ModelGroupName", default_value="ahla-aif-models")
p_train_instance = ParameterString(name="TrainInstanceType", default_value="ml.m5.xlarge")
p_train_steps = ParameterInteger(name="TrainMaxSteps", default_value=1000)

# Containers
sklearn_image = image_uris.retrieve(framework="sklearn", region=region, version="1.4-1")
xgboost_image = image_uris.retrieve(framework="xgboost", region=region, version="1.7-1")

# Steps (placeholders for your code/artifacts)
cache = CacheConfig(enable_caching=True, expire_after="30d")

# 1) Processing / feature build (placeholder)
from sagemaker.sklearn.processing import SKLearnProcessor
processor = SKLearnProcessor(framework_version="1.4-1", role=role, instance_type="ml.m5.xlarge", instance_count=1)
step_process = ProcessingStep(
    name="BuildFeatures",
    processor=processor,
    code="processors/build_features.py",  # add your file
    cache_config=cache
)

# 2) Train (placeholder - XGBoost classifier/regressor)
from sagemaker.estimator import Estimator
estimator = Estimator(
    image_uri=xgboost_image, role=role, instance_type=p_train_instance,
    instance_count=1, output_path=f"s3://{os.environ.get('SM_OUTPUT_BUCKET','your-bucket')}/aif/train/"
)
estimator.set_hyperparameters(
    objective="binary:logistic", num_round=100, max_depth=6, eta=0.2
)
step_train = TrainingStep(
    name="TrainModel",
    estimator=estimator,
    inputs={"train": step_process.properties.ProcessingOutputConfig.Outputs["train"].S3Output.S3Uri},
    cache_config=cache
)

# 3) Evaluation (JSON metrics)
eval_property = PropertyFile(name="EvalReport", output_name="evaluation", path="evaluation.json")
step_eval = ProcessingStep(
    name="EvaluateModel",
    processor=processor,
    code="processors/evaluate.py",
    inputs=[step_train.properties.ModelArtifacts.S3ModelArtifacts],
    property_files=[eval_property],
    cache_config=cache
)

# 4) Register into Model Registry
register_step = RegisterModel(
    name="RegisterToRegistry",
    estimator=estimator,
    model_data=step_train.properties.ModelArtifacts.S3ModelArtifacts,
    content_types=["application/json"],
    response_types=["application/json"],
    inference_instances=["ml.m5.large","ml.c5.large"],
    transform_instances=["ml.m5.large"],
    model_package_group_name=p_model_group,
    approval_status="PendingManualApproval",
    model_metrics=None
)

def create_pipeline():
    return Pipeline(
        name="Ahla-AIF-Pipeline",
        parameters=[p_model_group, p_train_instance, p_train_steps],
        steps=[step_process, step_train, step_eval, register_step],
        sagemaker_session=None
    )

if __name__ == "__main__":
    p = create_pipeline()
    print(p.definition())
