from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, TextOverviewPreset
import pandas as pd, os

def run(ref_csv, cur_csv, out_html):
    ref = pd.read_csv(ref_csv)
    cur = pd.read_csv(cur_csv)
    rep = Report(metrics=[DataDriftPreset(), TextOverviewPreset()])
    rep.run(reference_data=ref, current_data=cur)
    rep.save_html(out_html)
    print("Saved", out_html)

if __name__ == "__main__":
    os.makedirs("monitoring/evidently", exist_ok=True)
    run("monitoring/evidently/ref.csv","monitoring/evidently/current.csv","monitoring/evidently/report.html")
