import pandas as pd, numpy as np
from datetime import datetime, timedelta, timezone
from pathlib import Path

def run(input_csv='monitoring/evidently/current.csv', out_parquet='feast_repo/data/chat_metrics.parquet'):
    # Expect CSV columns at minimum: chat_id,message_id,author_id,text,created_at,reply_mins,sentiment_negative,flag_conflict
    try:
        df = pd.read_csv(input_csv)
    except FileNotFoundError:
        Path('feast_repo/data').mkdir(parents=True, exist_ok=True)
        pd.DataFrame([{
            'chat_id':'seed','message_id':'0','author_id':'seed','text':'seed','created_at':datetime.now(timezone.utc).isoformat(),
            'reply_mins':60,'sentiment_negative':0.4,'flag_conflict':False
        }]).to_csv(input_csv, index=False)
        df = pd.read_csv(input_csv)

    df['created_at'] = pd.to_datetime(df['created_at'], utc=True, errors='coerce')
    now = df['created_at'].max()
    last7 = now - timedelta(days=7); last14 = now - timedelta(days=14); last30 = now - timedelta(days=30)
    rows = []
    for chat_id, g in df.groupby('chat_id'):
        g7, g14, g30 = g[g['created_at']>=last7], g[g['created_at']>=last14], g[g['created_at']>=last30]
        rec = {
          'chat_id': chat_id, 'event_timestamp': now, 'created': now,
          'conflict_count_30d': int((g30['flag_conflict']==True).sum() if 'flag_conflict' in g30 else 0),
          'praise_count_7d': int((g7.get('sentiment_negative', 0.5) < 0.2).sum() if len(g7) else 0),
          'night_msgs_14d': int((g14['created_at'].dt.hour>=23).sum() if len(g14) else 0),
          'avg_response_hours_7d': float(np.nanmean(g7.get('reply_mins', np.nan))/60.0) if len(g7) else 0.0,
          'response_rate_1h_7d': float(np.nanmean((g7.get('reply_mins', np.inf)<=60).astype(float))) if len(g7) else 0.0,
          'avg_message_length_7d': float(np.nanmean(g7['text'].astype(str).str.len())) if len(g7) else 0.0,
          'positive_emoji_ratio_7d': float(np.nanmean(g7['text'].astype(str).apply(lambda s: sum(c in "😀😃😄😁😍🥰😊👍✨🎉💖❤️👏" for c in s)/max(len(s),1)))) if len(g7) else 0.0,
          'response_rate_15m_7d': float(np.nanmean((g7.get('reply_mins', np.inf)<=15).astype(float))) if len(g7) else 0.0,
          'tone_volatility_weekly': float(g7.set_index('created_at').resample('1D').agg({'sentiment_negative':'mean'}).fillna(0.5)['sentiment_negative'].std()) if len(g7) else 0.0,
        }
        rows.append(rec)
    Path('feast_repo/data').mkdir(parents=True, exist_ok=True)
    pd.DataFrame(rows).to_parquet(out_parquet, index=False)
    print('Wrote', out_parquet, 'rows', len(rows))

if __name__ == '__main__':
    run()
