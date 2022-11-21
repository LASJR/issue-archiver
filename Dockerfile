FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    httrack s3cmd zip ca-certificates msmtp
WORKDIR /app
COPY webhookd /app     
COPY scripts /app/scripts     
COPY endpoints /app/endpoints     
RUN chmod -R +x /app/scripts
RUN chmod -R +x /app/endpoints
ENTRYPOINT ["./webhookd", "-scripts", "/app/endpoints"]
