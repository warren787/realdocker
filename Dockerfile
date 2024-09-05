FROM alpine:latest

RUN apk update && \
    apk add --no-cache openssl curl bash gawk

WORKDIR /app

RUN curl -o docker-entrypoint.sh https://raw.githubusercontent.com/warren787/realdocker/main/docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh

CMD ["./docker-entrypoint.sh"]
