# dockcheck-web

A webpage showing available image updates for your running containers.

![side-by-side desktop and mobile screenshot of dockcheck-web](img/dockcheck-screenshot.png)

### Forked from [Palleri/dockcheck-web](https://github.com/Palleri/dockcheck-web)

## Changes from upstream dockcheck-web
* Data volume separate from the web app code
* Optional check on startup via the `CHECK_ON_LAUNCH` environment variable
* API endpoints to trigger update check, get status, and list updates
* Mobile-friendly styling using [Bulma](https://bulma.io/)
* Leaner entrypoint script
* Customizable page/window titles (`PAGE_TITLE`,`WINDOW_TITLE`)
* Show last update date/time on page (`TZ`)
* Troubleshooting options (`DEBUG`,`SILENCE_APACHE_LOGS`)

docker-compose.yml
```yml
version: '3.2'
services:
  dockcheck-web:
    container_name: dockcheck-web
    image: 'ghcr.io/supermamon/dockcheck-web:latest'
    restart: unless-stopped
    ports:
      - '8401:80'
    volumes:
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/localtime:/etc/localtime:ro
    environment:
      - NOTIFY=true # optional
      - NOTIFY_URLS=discord://Dockcheck-web@xxxxx/xxxxxx #optional
      - EXCLUDE=nginx,plex,prowlarr  #optional
      - CHECK_ON_LAUNCH=true # optional
      - PAGE_TITLE=Dockcheck # optional
      - WINDOW_TITLE=Dockcheck #optional
      - TZ=Europe/London #optional
```

---

## Configuration Options

### Environment Variables

| Variable            | Default   | Description                           |
| ------------------- | --------- | ------------------------------------- |
| NOTIFY              | false     | Enable notifications                  |
| NOTIFY_URLS         |           | See Notifications section             |
| EXCLUDE             |           | Exclude containers from update check  |
| HTTP_PROXY          |           |                                       |
| HTTPS_PROXY         |           |                                       |
| CHECK_ON_LAUNCH     | true      | Run `dockcheck` when container starts |
| PAGE_TITLE          | Dockcheck | Custom web page title                 |
| WINDOW_TITLE        | Dockcheck | Custom window title                   |
| TZ                  | UTC       | Timezone to use for displaying date/time on the page |
| DEBUG               |           | Set to 'true' to show debugging information in docker logs  |
| SILENCE_APACHE_LOGS |           | Set to 'true' to hide Apache logs     |

### Volumes

* `/data` : to store the list of updates. Mount if you want to persists the results of the last check even after restarting the container.

---

## Notifications
This image uses [apprise](https://github.com/caronc/apprise) for notifications.


Example notification setup  
```yml
version: '3.2'
services:
  ...
    environment:
      - NOTIFY=true
      - NOTIFY_URLS="slack://sometoken1/sometoken2/sometoken3/"
  ...
```

Example for multiple urls

```yml
version: '3.2'
services:
  ...
    environment:
      - NOTIFY=true
      - NOTIFY_URLS="discord://Dockcheck-web@xxxxx/xxxxxx tgram://0123456789:RandomLettersAndNumbers-2morestuff-123456789"
  ...
```
