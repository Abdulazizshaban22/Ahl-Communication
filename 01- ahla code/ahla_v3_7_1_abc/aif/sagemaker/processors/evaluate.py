import json
# Dummy evaluation metrics
with open('/opt/ml/processing/evaluation/evaluation.json','w') as f:
    json.dump({"accuracy":0.95}, f)
