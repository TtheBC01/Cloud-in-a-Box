![Alt Text](/demo.gif)

# Browser IDE

This repo uses the open-source [Theia](https://theia-ide.org/) framework to build a browser-based IDE, similar to VSCode, that
can be served from Docker container and used as an alternative to traditional RDP tools, particularly 
when coupled with an [authentication layer](https://github.com/greenpau/caddy-security) and an 
[introspective tunnel](https://www.cloudflare.com/products/tunnel/) technology. 

This repo is intended to be self-contained in that a developer should be able to use it as a stand-alone tool. To that end,
the browser ide uses [Caddy Server](https://caddyserver.com/) to provide form-based authentication when accessing the ide 
from a public URL. Additionally, the project uses [supervisord](http://supervisord.org/) for process control and 
automatic restarts of the caddy and node processes. 

## Requirements

1. [Docker Engine](https://docs.docker.com/engine/install/)
2. [Docker Compose](https://docs.docker.com/compose/install/)

## Building

To build the IDE environment, use the Docker cli:

```
docker build -t browser-ide .
```

## Pre-built Docker Image

A pre-built version of the browser-ide can be pulled from Docker Hub:

```
docker pull tthebc01/browser-ide
```

## Running the IDE

Once you have either built or pulled the ide container, you can run it locally by exposing port `8080` on the ide container:

```
docker run -p 8080:8080 --rm --name browser-ide -d browser-ide
```

To enable authentication, you'll need to expose port `8888` which is a reverse-proxy endpoint with authentication
provided by a caddy server plugin.

```
docker run -p 8888:8888 --rm --name browser-ide -d browser-ide
```

### NOTE: Username and Password

You should set the `AUTHP_ADMIN_USER` and `AUTHP_ADMIN_SECRET` environment variables in the `.env` file to 
appropriate values to properly setup the form-based login. I will eventually setup user registration so that 
the pre-built docker image can be used in production without changing anything.

### Docker in Docker

The browser-ide image includes the `docker.io` package so that the host's docker socket (which is mounted as a volume in 
the [`docker-compose.yml`](/docker-compose.yml#L6) file) can be manipulated as if the user was logged into the host machine. 
If you do not require this functionality, you may consider removing the socket mount from this file. 

### Remote Access for the IDE

This repository is setup to use Cloudflare Argo Tunnels as the introspective tunnel technology for 
exposing the IDE to the wider internet. Anonymous (non-authenticated) tunnels are currently not supported as 
the `caddy-security` plugin authentication cookie does not recognize the auth cookie domain properly, causing 
the form-based login page to fail. 

First, you must have a domain name managed by Cloudflare. Second, you must have Argo Tunnels enabled for 
the domain's account. Use the [Zero Trust dashboard](https://dash.teams.cloudflare.com/) to configure a new 
tunnel and configure your desired subdomain and service address. 

![Alt Text](/tunnel-config.png)

When you create a new tunnel in the 
dashboard, it will give you a tunnel token (a long string). Put the tunnel token in the `.env` file
as the value saved in the `TUNNEL_TOKEN` environment variable. Now, use the `docker-compose.yml` file to spin up 
a 2-service stack consisting of the browser-ide container and a public Argo Tunnel:

```
docker-compose up -d
```

Check that your tunnel client is running nominally:

```
docker logs argo-tunnel
```

The URL for your tunnel will be the subdomain you chose for your parent domain managed by your Cloudflare
account.

### TODO:

1. Add docker cli utilities to the base image so docker engine can be used remotely.
2. Make the login form prettier