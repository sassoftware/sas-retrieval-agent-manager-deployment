FROM alpine:3.19

RUN apk add --no-cache \
    bash \
    postgresql-client

COPY --chmod=755 *.sh /scripts/db/
RUN sed -i 's/\r$//' /scripts/db/*.sh

ENTRYPOINT ["/scripts/db/initialize-db.sh"]
