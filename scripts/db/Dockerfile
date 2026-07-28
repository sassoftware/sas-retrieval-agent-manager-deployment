FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    postgresql-client

COPY --chmod=755 *.sh /scripts/db/

ENTRYPOINT ["/scripts/db/initialize-db.sh"]
