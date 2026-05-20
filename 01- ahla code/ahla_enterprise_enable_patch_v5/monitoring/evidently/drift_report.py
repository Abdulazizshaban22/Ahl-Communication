from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, TextOverviewPreset
import pandas as pd, os, pathlib

def run(ref_csv='monitoring/evidently/ref.csv', cur_csv='monitoring/evidently/current.csv', out_html='monitoring/evidently/report.html'):
    pathlib.Path('monitoring/evidently').mkdir(parents=True, exist_ok=True)
    if not os.path.exists(ref_csv):
        pd.DataFrame({'chat_id':[], 'message_id':[], 'text':[], 'created_at':[]}).to_csv(ref_csv, index=False)
    if not os.path.exists(cur_csv):
        pd.DataFrame({'chat_id':[], 'message_id':[], 'text':[], 'created_at':[]}).to_csv(cur_csv, index=False)
    ref = pd.read_csv(ref_csv)
    cur = pd.read_csv(cur_csv)
    rep = Report(metrics=[DataDriftPreset(), TextOverviewPreset()])
    rep.run(reference_data=ref, current_data=cur)
    rep.save_html(out_html)
    print('Saved', out_html)

if __name__ == '__main__':
    run()
