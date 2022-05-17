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

## Requirments

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
### Remote Access for the IDE

Use the docker-compose file to spin up a 2-service stack consisting of the browser-ide container and a
argo tunnel:

```
docker-compose up -d
```

The public URL for your IDE will be in the logs of the `argo-tunnel` container:

```
docker logs argo-tunnel
```

### NOTE: Username and Password

You should set the `AUTHP_ADMIN_USER` and `AUTHP_ADMIN_SECRET` environment 
variables in the Dockerfile then rebuild your own image in order to properly
setup the form-based login. I will eventually setup user registration so that the 
pre-built docker image can be used in production without changing anything.

### TODO:

1. Write a docker-compose file to bring up IDE stack with argo tunnel.
2. Add docker cli utilities to the base image so docker engine can be used remotely.
3. Figure out what is causing the user to have to provide credentials twice.
4. Make the login form prettier