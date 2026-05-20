from evidently.report import Report
from evidently.metric_preset import DataDriftPreset
import pandas as pd, os

os.makedirs("artifacts", exist_ok=True)
ref = pd.DataFrame({"x":[1,2,3], "y":[1,1,2]})
cur = pd.DataFrame({"x":[2,3,4], "y":[1,2,3]})
r = Report(metrics=[DataDriftPreset()])
r.run(reference_data=ref, current_data=cur)
r.save_html("artifacts/chat_drift.html")
print("Saved artifacts/chat_drift.html")
