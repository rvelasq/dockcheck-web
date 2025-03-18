FROM php:8.3-apache
LABEL org.opencontainers.image.authors="dev@velasq.com"
LABEL org.opencontainers.image.description="Image updates for your running containers"
LABEL org.opencontainers.image.url="https://github.com/rvelasq/dockcheck-web"
LABEL org.opencontainers.image.source=https://github.com/rvelasq/dockcheck-web

ARG ARCH
ARG DOCKCHECK_VERSION=0.5.8.0
ARG REGCTL_VERSION=0.8.2  #0.4.5
ARG DCW_VERSION=0

WORKDIR /app
VOLUME /data

RUN apt update \
&& apt install cron docker.io inotify-tools pipx -y \
&& mkdir -p /var/www/{tmp,html} \
&& curl -sL "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css" -o /var/www/html/bulma.min.css \
&& pipx install apprise \
&& rm -rf /etc/crontab \
&& rm -rf /etc/cron.daily/* \
&& curl -sL "https://raw.githubusercontent.com/mag37/dockcheck/refs/tags/v${DOCKCHECK_VERSION}/extras/dc_brief.sh" -o /app/dockcheck.sh \
&& chmod +x /app/dockcheck.sh \
&& case ${ARCH} in \
         "linux/amd64")  os=amd64  ;; \
         "linux/arm64")  os=arm64  ;; \
    esac \
&& curl -sL "https://github.com/regclient/regclient/releases/download/v${REGCTL_VERSION}/regctl-linux-${os}" -o /usr/bin/regctl \
&& chmod +x /usr/bin/regctl


ENV NOTIFY="false" \
NOTIFY_URLS="" \
EXCLUDE="" \
CHECK_ON_LAUNCH="true" \
DEBUG="false" \
SCHEDULE="0 8 * * *" \
DCW_VERSION="${DCW_VERSION}"

# COPY app /app
COPY app/web /var/www/html/
COPY app/etc /etc/
COPY app/bin /app/


RUN chmod +x /etc/cron.custom/dockcheck \
&& chmod +x /app/watcher.sh \
&& $( [ ! -d "/data" ] && mkdir /data) \
&& echo "0" > /data/containers \ 
&& mkdir /data/logs

ENTRYPOINT ["/app/entrypoint.sh"]