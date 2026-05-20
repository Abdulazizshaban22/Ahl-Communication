# Compute chat-level features and write to Parquet for Feast offline store
import pandas as pd, numpy as np, os, json
from datetime import datetime, timedelta, timezone
from pathlib import Path

def is_positive_emoji(ch):
    # simple whitelist
    return ch in ['😀','😃','😄','😁','😍','🥰','😊','👍','✨','🎉','💖','❤️','👏']

def positive_emoji_ratio(text):
    if not isinstance(text, str) or not text: return 0.0
    total = sum(1 for _ in text)
    pos = sum(1 for c in text if is_positive_emoji(c))
    return float(pos)/float(total) if total else 0.0

def run(input_csv="message_analytics.csv", out_parquet="data/chat_metrics.parquet"):
    df = pd.read_csv(input_csv)  # expected cols: chat_id,message_id,author_id,text,created_at,sentiment_negative,flag_conflict
    df['created_at'] = pd.to_datetime(df['created_at'])
    now = df['created_at'].max() if len(df) else datetime.now(timezone.utc)

    # time windows
    last7 = now - timedelta(days=7)
    last14 = now - timedelta(days=14)
    last30 = now - timedelta(days=30)

    # response within 1h (approx): requires reply_time_mins column if available
    if 'reply_mins' not in df.columns:
        df['reply_mins'] = np.nan
    df['len'] = df['text'].astype(str).str.len()
    df['pos_emoji_ratio'] = df['text'].apply(positive_emoji_ratio)

    rows = []
    for chat_id, g in df.groupby('chat_id'):
        g7 = g[g['created_at']>=last7]
        g14 = g[g['created_at']>=last14]
        g30 = g[g['created_at']>=last30]

        conflict_count_30d = int((g30['flag_conflict'] == True).sum())
        praise_count_7d = int((g7['sentiment_negative'] < 0.2).sum())  # proxy
        night_msgs_14d = int((g14['created_at'].dt.hour >= 23).sum())
        avg_response_hours_7d = float(np.nanmean(g7['reply_mins'])/60.0) if len(g7) else 0.0

        response_rate_1h_7d = float(np.nanmean((g7['reply_mins']<=60).astype(float))) if len(g7) else 0.0
        avg_message_length_7d = float(np.nanmean(g7['len'])) if len(g7) else 0.0
        positive_emoji_ratio_7d = float(np.nanmean(g7['pos_emoji_ratio'])) if len(g7) else 0.0

        rows.append({
            "chat_id": chat_id,
            "event_timestamp": now,
            "created": now,
            "conflict_count_30d": conflict_count_30d,
            "praise_count_7d": praise_count_7d,
            "night_msgs_14d": night_msgs_14d,
            "avg_response_hours_7d": avg_response_hours_7d,
            "response_rate_1h_7d": response_rate_1h_7d,
            "avg_message_length_7d": avg_message_length_7d,
            "positive_emoji_ratio_7d": positive_emoji_ratio_7d
        })
    out_dir = Path(out_parquet).parent
    out_dir.mkdir(parents=True, exist_ok=True)
    out_df = pd.DataFrame(rows)
    out_df.to_parquet(out_parquet, index=False)
    print("Wrote", out_parquet, "rows:", len(out_df))

if __name__ == "__main__":
    run()
