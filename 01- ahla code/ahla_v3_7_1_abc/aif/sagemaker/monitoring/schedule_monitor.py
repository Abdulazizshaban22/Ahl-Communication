# Create a Model Monitor schedule (data quality or Clarify bias)
import boto3, os, json

region = os.getenv("AWS_REGION","me-central-1")
sm = boto3.client("sagemaker", region_name=region)

def create_schedule(schedule_name, endpoint_name, s3_uri):
    resp = sm.create_monitoring_schedule(
        MonitoringScheduleName=schedule_name,
        MonitoringScheduleConfig={
            "ScheduleConfig":{"ScheduleExpression":"cron(0 * * * ? *)"},  # hourly
            "MonitoringJobDefinition":{
                "MonitoringAppSpecification":{
                    "ImageUri":"159807026194.dkr.ecr."+region+".amazonaws.com/sagemaker-model-monitor-analyzer",
                    "ContainerArguments":["--analysis-type","model-quality"]
                },
                "MonitoringInputConfig":{
                    "EndpointInput":{"EndpointName":endpoint_name, "LocalPath":"/opt/ml/processing/input/endpoint"}
                },
                "MonitoringOutputConfig":{
                    "MonitoringOutputs":[{"S3Output":{"S3Uri":s3_uri,"LocalPath":"/opt/ml/processing/output"}}]
                },
                "MonitoringResources":{"ClusterConfig":{"InstanceCount":1,"InstanceType":"ml.m5.xlarge","VolumeSizeInGB":20}}
            }
        }
    )
    print(resp)

if __name__ == "__main__":
    create_schedule("ahla-aif-hourly", os.environ["SAGEMAKER_ENDPOINT"], "s3://YOUR-BUCKET/aif/monitor/")
