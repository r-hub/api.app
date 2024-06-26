The R-hub API
================

> ## ARCHIVED
>
> We don’t use this app any more, and this repo is now archived. We use
> the [r-hub/search](https://github.com/r-hub/search) app for the CRAN
> package search, and the
> [r-hub/rversions.app](https://github.com/r-hub/rversions.app) app for
> the R-versions API.

<hr/>

This is the app serving the APIs at <https://api.r-hub.io>

## The APIs

-   R versions API:
    -   Served at <https://api.r-hub.io/rversions>
    -   Implementation an issue tracker at
        <https://github.com/r-hub/rversions.app>
-   CRAN package search API:
    -   Served at <https://api.r-hub.io/pkgsearch>
    -   Implementation is in this repo

## Maintainer notes

The APIs are served via Docker Swarm, from a VM in Azure. Originally
created with `docker-machine`, but we don’t use `docker-machine` any
more. People that need shell access, need their public ssh keys in
`authorized_keys` for the `docker-user` user.

### HTTPS certificates

Coming from <https://letsencrypt.org/>

To obtain the first certs, you can run this command on the Docker Swarm
VM:

``` sh
docker run -v api_certbot-etc:/etc/letsencrypt \
  -v api_certbot-var:/var/lib/letsencrypt -v api_web-root:/var/www/html -ti \
  certbot/certbot certonly --webroot --webroot-path=/var/www/html  \
  --email csardi.gabor@gmail.com --agree-tos --no-eff-email -d api.r-hub.io
```

And the same for `search.r-pkg.org` or any of the other domains we want
to serve.

Renewal is handled automatically by the `certbot` service. We reload the
nginx config every 6 hours, to pick up the renewed certs.

### Local testing

You need an `x86_64` Linux machine or VM for this, because the
elasticsearch containers are `x86_64` only. I used Ubuntu Focal in a
VirtualBox VM on an `x86_64` laptop. Possibly multipass would work as
well, I switched to VirtualBox because of some initial trouble with
multipess, which then turned out to be unrelated.

Requirements:

-   Docker
-   docker-compose (not strictly needed, but easier to build the images)
-   mkcert
-   root access

1.  Add `api.r-hub.io` and `search.r-pkg.org` to `/etc/hosts`:
    `127.0.0.1 api.r-hub.io     127.0.0.1 search.r-pkg.org`

2.  Set up Docker Swarm:

        docker swarm init

3.  Install mkcert from from
    <https://github.com/FiloSottile/mkcert#linux> I used the pre-built
    binary.

4.  Call `./cert/local_certs.sh` to set up locally generated
    certificates for `api.r-hub.io` and the other hosts we serve. This
    also makse sure that the local Linux accepts these certs.

5.  You might need to create an `app-insights-key` secret. I don’t think
    it needs to contain the real key, I think an empty string should be
    OK. Or comment out the `secrets:` line plus the next line from the
    `rversions` service in `docker-compose.yml`.

6.  If you modified the Docker images that are built from this repo,
    then run

    ``` sh
    docker-compose build
    docker-compose push
    ```

    Yes, you need to push, unfortunately, otherwise
    `docker stack deploy` will not pick up the new image. So to avoid
    messing up the production service, you probably want to increase the
    version number of the image in `docker-compose.yml` first.

7.  Run `docker stack deploy -c docker-compose.yml api` You might need
    to run this again, if some services do not start up. This typically
    happened to me because nginx cannot start without elasticsearch, and
    elasticsearch starts up slowly, so by the time it is up, nginx has
    given up. I increased `restart_policy.max_attempts` to 100 for
    nginx, so it should not happen again, but in general the
    dependencies are hard to handle graciously, so some error might
    happen at first startup.

To update a running service, repeat the last step, or the last two
steps, depending on what you have changed.

### Running the service

Pretty much `docker stack deploy -c docker-compose.yml api` is all you
need to do.

### `rversions` notes

This is pretty straightforward, and is (well, should be) documented in
the external <https://github.com/r-hub/rversions.app> and
<https://github.com/r-hub/node-rversions> repos.

### `pkgsearch` notes

The logstash service has the CRANdb (<https://github.com/r-hub/crandb>)
service’s changes feed in its input. This uses a custom filter, see
`cradb-filter.rb`.

The number of reverse dependencies and the number of downloads are not
in the CRANdb documents, these are taken from another CRANdb table, and
from <https://cranlogs.r-pkg.org> , respectively. The search-cron
service runs daily to update them, see the `cron/index.js` file.

### nginx notes

We cannot redirect http -\> https for search-r-pkg.org, because there is
no good way to redirect a POST request, and the pkgsearch API needs POST
requests. <https::/api.r-hub.io/pkgsearch> only works on HTTPS for the
same reason.

### Health checks and zero downtime deployment

The rversions, nginx, elasticsearch and logstash services have health
checks, and they are also set up for zero downtime deployment. (The
other services do not need to run continuously to serve the APIs.)

In the health checks, it is important to refer to 127.0.0.1, because
Docker assigns the host names late. (Possibly after a successful health
check?)

## License

MIT @ [Gábor Csárdi](https://github.com/gaborcsardi),
[RStudio](https://github.com/rstudio), [R
Consortium](https://www.r-consortium.org/).
