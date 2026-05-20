#!/usr/bin/env bash
set -e
WATCH_DIR=${WATCH_DIR:-/data/moments}
THUMBS_DIR=${THUMBS_DIR:-/data/thumbs}
mkdir -p "$WATCH_DIR" "$THUMBS_DIR"
echo "[moments-worker] watching $WATCH_DIR"
inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read FILE; do
  echo "[moments-worker] new file: $FILE"
  BASENAME="${FILE%.*}"
  # Create a JPG thumbnail at 320px width
  ffmpeg -y -i "$WATCH_DIR/$FILE" -vf "thumbnail,scale=320:-1" -frames:v 1 "$THUMBS_DIR/${BASENAME}.jpg" </dev/null >/dev/null 2>&1 || true
done