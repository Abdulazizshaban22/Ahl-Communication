import os, json, boto3, time

CW = boto3.client('cloudwatch')
NAMESPACE = os.environ.get('NAMESPACE', 'Ahla/OPS')

def handler(event, context):
  value = float(event.get('value', 1))
  CW.put_metric_data(
    Namespace=NAMESPACE,
    MetricData=[{
      'MetricName':'MaintenanceMode',
      'Timestamp': int(time.time()),
      'Value': value,
      'Unit':'Count'
    }]
  )
  return {'ok': True, 'value': value}
