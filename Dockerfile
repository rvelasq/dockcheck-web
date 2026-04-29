FROM alpine:latest AS download

ARG DOCKCHECK_VERSION=0.7.7
ARG REGCTL_VERSION=0.11.3

WORKDIR /app

RUN apk add curl \
    && curl -sL https://github.com/mag37/dockcheck/archive/refs/tags/v${DOCKCHECK_VERSION}.zip -o /tmp/pb.zip \
    && unzip /tmp/pb.zip -d /tmp/ \
    && mv /tmp/dockcheck-${DOCKCHECK_VERSION}/dockcheck.sh /app/ \
    && chmod +x /app/dockcheck.sh \
    && case $(uname -m) in \
    "x86_64")  arch=linux-amd64  ;; \
    "arm64")  arch=linux-arm64  ;; \
    "aarch64")  arch=linux-arm64  ;; \
    esac \ 
    && curl -sL https://github.com/regclient/regclient/releases/download/v${REGCTL_VERSION}/regctl-${arch} -o /tmp/regctl \
    && chmod +x /tmp/regctl

FROM php:8.4-apache
LABEL org.opencontainers.image.authors="dev@velasq.com"
LABEL org.opencontainers.image.description="Image updates for your running containers"
LABEL org.opencontainers.image.url="https://github.com/rvelasq/dockcheck-web"
LABEL org.opencontainers.image.source=https://github.com/rvelasq/dockcheck-web

ARG DOCKCHECK_VERSION=0.7.7
ARG REGCTL_VERSION=0.11.3
ARG DCW_VERSION=0

WORKDIR /app
VOLUME /data

RUN apt update && apt install cron docker.io inotify-tools pipx jq -y \
    && mkdir -p /var/www/{tmp,html} \
    && curl -sL "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" -o /var/www/html/bulma.min.css \    
    && pipx install apprise \
    && rm -rf /etc/crontab \
    && rm -rf /etc/cron.daily/* 

ENV NOTIFY="false" \
    NOTIFY_URLS="" \
    EXCLUDE="" \
    CHECK_ON_LAUNCH="true" \
    DEBUG="false" \
    SCHEDULE="0 8 * * *" \
    DCW_VERSION="${DCW_VERSION}"

COPY --from=download /tmp/regctl /usr/bin/
COPY --from=download /app /app

COPY app/etc /etc/
COPY app/bin /app/
COPY app/web /var/www/html

RUN chmod +x /etc/cron.custom/dockcheck \
    && chmod +x /app/watcher.sh \
    && $( [ ! -d "/data" ] && mkdir /data) \
    && echo "0" > /data/containers \ 
    && mkdir /data/logs

ENTRYPOINT ["/app/entrypoint.sh"]