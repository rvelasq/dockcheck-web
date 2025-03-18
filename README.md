# dockcheck-web

A webpage showing available image updates for your running containers.

![side-by-side desktop and mobile screenshot of dockcheck-web](img/dockcheck-screenshot.png)

### Forked from [Palleri/dockcheck-web](https://github.com/Palleri/dockcheck-web)

## Changes from upstream dockcheck-web

- Data volume separate from the web app code
- Optional check on startup via the `CHECK_ON_LAUNCH` environment variable
- API endpoints to trigger update check, get status, and list updates
- Mobile-friendly styling using [Bulma](https://bulma.io/)
- Leaner entrypoint script
- Customizable page/window titles (`PAGE_TITLE`,`WINDOW_TITLE`)
- Show last update date/time on page (`TZ`)
- Troubleshooting options (`DEBUG`,`SILENCE_APACHE_LOGS`)
- Custom scheduling (`SCHEDULE`)

docker-compose.yml

```yml
services:
  dockcheck-web:
    container_name: dockcheck-web
    image: "ghcr.io/rvelasq/dockcheck-web:latest"
    restart: unless-stopped
    ports:
      - "8401:80"
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - NOTIFY=true
      - NOTIFY_URLS=discord://Dockcheck-web@xxxxx/xxxxxx
      - EXCLUDE=nginx,plex,prowlarr
      - CHECK_ON_LAUNCH=true
      - PAGE_TITLE=Dockcheck
      - WINDOW_TITLE=Dockcheck
      - TZ=Europe/London
      - SCHEDULE=0 8 * * *
```

---

## Configuration Options

### Environment Variables

| Variable            | Default      | Description                                                |
| ------------------- | ------------ | ---------------------------------------------------------- |
| NOTIFY              | false        | Enable notifications                                       |
| NOTIFY_URLS         |              | See Notifications section                                  |
| EXCLUDE             |              | Exclude containers from update check                       |
| HTTP_PROXY          |              |                                                            |
| HTTPS_PROXY         |              |                                                            |
| CHECK_ON_LAUNCH     | true         | Run `dockcheck` when container starts                      |
| PAGE_TITLE          | Dockcheck    | Custom web page title                                      |
| WINDOW_TITLE        | Dockcheck    | Custom window title                                        |
| TZ                  | UTC          | Timezone to use for displaying date/time on the page       |
| DEBUG               | fals         | Set to 'true' to show debugging information in docker logs |
| SILENCE_APACHE_LOGS | true         | Set to 'true' to hide Apache logs                          |
| SCHEDULE            | 0 8 \* \* \* | cron-style schedule                                        |

### Volumes

- `/data` : to store the list of updates. Mount if you want to persists the results of the last check even after restarting the container.

---

## Notifications

This image uses [apprise](https://github.com/caronc/apprise) for notifications.

Example notification setup

```yml
services:
  ...
    environment:
      - NOTIFY=true
      - NOTIFY_URLS="slack://sometoken1/sometoken2/sometoken3/"
  ...
```

Example for multiple urls

```yml
services:
  ...
    environment:
      - NOTIFY=true
      - NOTIFY_URLS="discord://Dockcheck-web@xxxxx/xxxxxx tgram://0123456789:RandomLettersAndNumbers-2morestuff-123456789"
  ...
```

## Versions

### 1.3.1

- fix 'apprise not found' error

### 1.3.0

- update to dockcheck 0.5.8.0
- fix CHECK_ON_LAUNCH not running checks
- build improvements

### 1.2.0

- Custom scheduling
- add `host` to the `/api/updates/` endpoint

### 1.1.0

- APIs on their own directory
- Add `hostname` to `/api/updates/` endpoint
- DCW_VERSION variable to get application version

### 1.0.3

- Troubleshooting options

### 1.0.2

- EXCLUDE configuration
- Show last update check on page

  1.0.0

- Mobile friendly layout
- API endpoints
- build & deploy script
