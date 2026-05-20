from datetime import timedelta
from feast import Entity, Field, FeatureView, FileSource, ValueType
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
    ],
    online=True,
    source=source,
)
