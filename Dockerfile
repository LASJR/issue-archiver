FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    httrack s3cmd zip
WORKDIR /app
COPY entrypoint.sh /app     
ENTRYPOINT ["./entrypoint.sh"]
