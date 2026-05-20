FROM alpine:3.20
RUN apk add --no-cache ffmpeg inotify-tools
WORKDIR /app
COPY src/worker.sh ./worker.sh
VOLUME ["/data"]
ENTRYPOINT ["./worker.sh"]