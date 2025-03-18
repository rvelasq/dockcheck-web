#!/bin/sh

echo "     __         __       __           __                  __ "
echo " ___/ /__  ____/ /______/ /  ___ ____/ /_______    _____ / / "
echo "/ _  / _ \\/ __/  '_/ __/ _ \\/ -_) __/  '_/___/ |/|/ / -_) _ \\"
echo "\_,_/\\___/\\___/_/\_\\\\__/_//_/\\__/\\__/_/\\_\    |__,__/\\__/_.__/"
echo " "                                                             

export -p > /app/ENV

[ "$DEBUG" = "true" ] && echo "*** DEBUGGING IS ACTIVATED ***" 

echo "* starting dockcheck-web v$DCW_VERSION"

if [ "$NOTIFY" = "true" ]; then
    [ -n "$NOTIFY_URLS" ] && echo "* notifications activated"
fi

echo "* setting up web app"
chown www-data:www-data /var/www/html/*
chown www-data:www-data /data
chmod 777 /data
[ -f "/data/containers" ] || echo '0' > /data/containers
[ -f "/data/containers" ] && chown www-data:www-data /data/*
[ -f "/data/containers" ] && chmod 777 /data/*

mkdir -p /data/logs || true

if [ -n "$SCHEDULE" ]; then 
    echo "* adding cron schedule"
    echo "$SCHEDULE root  test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.custom )"  >> /etc/crontab
fi

echo "* starting cron"
if [ "$DEBUG" = "true" ]; then
    echo "* DEBUG: $0 adding crontest to cron"
    echo "  *  *  *  *  * root    /app/crontest.sh" >> /etc/crontab
    service cron start
else
    service cron start >/dev/null  2>&1 &
fi  

echo "* running watcher"
/app/watcher.sh & #</dev/null >/dev/null 2>&1 &

if [ "$CHECK_ON_LAUNCH" = "true" ]; then
    echo "* running launch-time dockcheck"
    run-parts /etc/cron.custom/ &
else
    echo "* skipping dockcheck on launch"
fi

echo "* starting web server"
if [ "$SILENCE_APACHE_LOGS" = "true" ]; then
  ln -fs /dev/null /var/log/apache2/access.log
fi
echo "ServerName localhost" >> /etc/apache2/apache2.conf
echo ""
exec apache2-foreground
