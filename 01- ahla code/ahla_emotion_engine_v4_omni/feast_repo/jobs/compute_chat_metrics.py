# Compute omni features for Feast offline store from message analytics CSV
import pandas as pd, numpy as np, os, re
from datetime import datetime, timedelta, timezone
from pathlib import Path

URL_RE = re.compile(r'https?://\S+')

def is_weekend(ts): return ts.weekday() >= 5

def burstiness(counts):
    # simple coefficient of variation on hourly counts
    if len(counts) < 2: return 0.0
    return float(np.std(counts) / (np.mean(counts) + 1e-6))

def run(input_csv='message_analytics.csv', out_parquet='data/chat_metrics.parquet'):
    df = pd.read_csv(input_csv)
    # expected columns: chat_id,message_id,author_id,text,created_at,reply_mins,sentiment_negative,flag_conflict,is_attachment,is_call
    df['created_at'] = pd.to_datetime(df['created_at'], utc=True, errors='coerce')
    df = df.dropna(subset=['created_at'])
    now = df['created_at'].max() if len(df) else datetime.now(timezone.utc)
    last7, last14, last30 = now - timedelta(days=7), now - timedelta(days=14), now - timedelta(days=30)

    rows = []
    for chat_id, g in df.groupby('chat_id'):
        g = g.sort_values('created_at')
        g7, g14, g30 = g[g['created_at']>=last7], g[g['created_at']>=last14], g[g['created_at']>=last30]
        # basics
        conflict_count_30d = int((g30['flag_conflict'] == True).sum()) if 'flag_conflict' in g30 else 0
        praise_count_7d = int((g7.get('sentiment_negative', pd.Series(0.5, index=g7.index)) < 0.2).sum())
        night_msgs_14d = int((g14['created_at'].dt.hour >= 23).sum())
        avg_response_hours_7d = float(np.nanmean(g7.get('reply_mins', np.nan))/60.0) if len(g7) else 0.0
        # extra
        response_rate_1h_7d = float(np.nanmean((g7.get('reply_mins', np.inf)<=60).astype(float))) if len(g7) else 0.0
        response_rate_15m_7d = float(np.nanmean((g7.get('reply_mins', np.inf)<=15).astype(float))) if len(g7) else 0.0
        avg_message_length_7d = float(np.nanmean(g7['text'].astype(str).str.len())) if len(g7) else 0.0
        positive_emoji_ratio_7d = float(np.nanmean(g7['text'].astype(str).apply(lambda s: sum(c in '😀😃😄😁😍🥰😊👍✨🎉💖❤️👏' for c in s)/max(len(s),1)))) if len(g7) else 0.0
        # tone volatility: std of daily negative sentiment mean (7d)
        if len(g7):
            daily = g7.set_index('created_at').resample('1D').agg({'sentiment_negative':'mean'}).fillna(0.5)
            tone_volatility_weekly = float(daily['sentiment_negative'].std())
        else:
            tone_volatility_weekly = 0.0
        # intermessage median minutes
        if len(g7) >= 2:
            diffs = g7['created_at'].diff().dt.total_seconds().dropna()/60.0
            median_intermsg_mins_7d = float(np.median(diffs)) if len(diffs) else 0.0
        else:
            median_intermsg_mins_7d = 0.0
        # weekend ratio 30d
        weekend_ratio_30d = float(np.mean(g30['created_at'].apply(is_weekend))) if len(g30) else 0.0
        # unique participants 30d
        unique_participants_30d = int(g30['author_id'].nunique()) if len(g30) else 0
        # burstiness: hourly counts in last 7d
        if len(g7):
            hourly = g7.set_index('created_at').resample('1H').size()
            burstiness_score_7d = float(burstiness(hourly.values))
        else:
            burstiness_score_7d = 0.0
        # longest negative streak (rolling)
        neg = (g30.get('sentiment_negative', pd.Series(0.5, index=g30.index)) > 0.6).astype(int).values
        negative_streak_max_30d = int(max((sum(1 for _ in group) for val, group in __import__('itertools').groupby(neg) if val), default=0))
        # links / attachments / calls in 7d
        links_shared_7d = int(g7['text'].astype(str).apply(lambda s: 1 if URL_RE.search(s) else 0).sum())
        attachments_shared_7d = int(g7.get('is_attachment', pd.Series(False, index=g7.index)).sum())
        calls_started_7d = int(g7.get('is_call', pd.Series(False, index=g7.index)).sum())
        # late night sessions (30d): sequences >= 15 msgs after 23:00
        g30['hour'] = g30['created_at'].dt.hour
        late = g30[g30['hour']>=23]
        late_night_sessions_30d = 1 if len(late)>=15 else 0

        rows.append({
            "chat_id": chat_id, "event_timestamp": now, "created": now,
            "conflict_count_30d": conflict_count_30d,
            "praise_count_7d": praise_count_7d,
            "night_msgs_14d": night_msgs_14d,
            "avg_response_hours_7d": avg_response_hours_7d,
            "response_rate_1h_7d": response_rate_1h_7d,
            "avg_message_length_7d": avg_message_length_7d,
            "positive_emoji_ratio_7d": positive_emoji_ratio_7d,
            "response_rate_15m_7d": response_rate_15m_7d,
            "tone_volatility_weekly": tone_volatility_weekly,
            "median_intermsg_mins_7d": median_intermsg_mins_7d,
            "weekend_ratio_30d": weekend_ratio_30d,
            "unique_participants_30d": unique_participants_30d,
            "burstiness_score_7d": burstiness_score_7d,
            "negative_streak_max_30d": negative_streak_max_30d,
            "links_shared_7d": links_shared_7d,
            "attachments_shared_7d": attachments_shared_7d,
            "calls_started_7d": calls_started_7d,
            "late_night_sessions_30d": late_night_sessions_30d
        })
    out = Path(out_parquet)
    out.parent.mkdir(parents=True, exist_ok=True)
    pd.DataFrame(rows).to_parquet(out, index=False)
    print("Wrote", out)
if __name__ == "__main__":
    run()
