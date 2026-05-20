from datetime import timedelta
from feast import Entity, Field, FeatureView, FileSource
from feast.types import Int64, Float32
from feast.data_format import ParquetFormat

chat = Entity(name="chat_id", join_keys=["chat_id"])

source = FileSource(
    path="data/chat_metrics.parquet",
    timestamp_field="event_timestamp",
    created_timestamp_column="created",
    file_format=ParquetFormat(),
)

chat_metrics_view = FeatureView(
    name="chat_metrics",
    entities=[chat],
    ttl=timedelta(days=90),
    schema=[
        Field(name="conflict_count_30d", dtype=Int64),
        Field(name="praise_count_7d", dtype=Int64),
        Field(name="night_msgs_14d", dtype=Int64),
        Field(name="avg_response_hours_7d", dtype=Float32),
        Field(name="response_rate_1h_7d", dtype=Float32),
        Field(name="avg_message_length_7d", dtype=Float32),
        Field(name="positive_emoji_ratio_7d", dtype=Float32),
        # New omni features:
        Field(name="response_rate_15m_7d", dtype=Float32),
        Field(name="tone_volatility_weekly", dtype=Float32),
        Field(name="median_intermsg_mins_7d", dtype=Float32),
        Field(name="weekend_ratio_30d", dtype=Float32),
        Field(name="unique_participants_30d", dtype=Int64),
        Field(name="burstiness_score_7d", dtype=Float32),
        Field(name="negative_streak_max_30d", dtype=Int64),
        Field(name="links_shared_7d", dtype=Int64),
        Field(name="attachments_shared_7d", dtype=Int64),
        Field(name="calls_started_7d", dtype=Int64),
        Field(name="late_night_sessions_30d", dtype=Int64),
    ],
    online=True,
    source=source,
)
