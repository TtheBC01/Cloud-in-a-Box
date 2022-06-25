![Alt Text](/demo.gif)

# Cloud-in-a-Box

This template repository implements a docker stack that can act as your own personal, lightweight, micro-cloud setup. 
The stack uses the open-source [Theia](https://theia-ide.org/) framework to build a browser-based IDE, similar 
to VSCode, that is served from Docker container. An [authentication layer](https://github.com/greenpau/caddy-security) 
is provided by Caddy and public hosting is handled by [Argo Tunnel](https://www.cloudflare.com/products/tunnel/).
Additionally, the IDE and caddy processes are handled by [supervisord](http://supervisord.org/) for process control 
and automatic restarts. 

Several services are created for monitoring:
- [glances](https://nicolargo.github.io/glances/) is used for host resource monitoring
- [cAdvisor](https://github.com/google/cadvisor) provides detailed container metrics
- [Prometheus](https://prometheus.io/) stores time series data collected from glances and cAdvisor
- [Grafana]() dashboards are provisioned for visualization of host resource utilization and Caddy Server load

Lastly, an [IPFS](https://ipfs.io/) node is included for content delivery and basic object storage functionality. 

This repo is intended to be self-contained in that a developer should be able to use it as a stand-alone tool. However,
it can also serve as a template project for specialized applications like Web 3.0 infrastructure hosting or remote access
for machine learning rigs. 

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

## Running the Stack

Important environment variables are configured in the [`.env`](.env) file. 

### Step 1: Username and Password

You should set the `AUTHP_ADMIN_USER` and `AUTHP_ADMIN_SECRET` environment variables in the `.env` file to 
appropriate values to properly setup the form-based login. I will eventually setup user registration so that 
the pre-built docker image can be used in production without changing anything. 

### Step 2: Get an Argo Tunnel Token

This repository is setup to use Cloudflare Argo Tunnels as the introspective tunnel technology for exposing the 
IDE to the wider internet. This could be replaced with something like [NGrok](https://ngrok.com/). Anonymous 
(non-authenticated) tunnels can be supported by tweaking the [Caddyfile](/browser-ide/Caddyfile) appropriately. 

You must have a domain name managed by Cloudflare. Second, you must have Argo Tunnels enabled for 
the domain's account. Use the [Zero Trust dashboard](https://dash.teams.cloudflare.com/) to configure a new 
tunnel and configure your desired subdomain and service address. 

![Alt Text](/tunnel-config.png)

When you create a new tunnel in the dashboard, it will give you a tunnel token (a long string). Put the tunnel 
token in the `.env` file as the value saved in the `TUNNEL_TOKEN` environment variable.

### Step 3: Docker Compose

Now, use the `docker-compose.yml` file to spin up a stack consisting of the browser-ide container, an Argo Tunnel
instance, and several monitoring services:

```
docker compose up -d
```

Check that your tunnel client is running nominally:

```
docker logs argo-tunnel
```

The URL for your tunnel will be the subdomain you chose for your parent domain managed by your Cloudflare
account.

## Docker in Docker

The browser-ide image includes the `docker.io` package so that the host's docker socket (which is mounted as a volume in 
the [`docker-compose.yml`](/docker-compose.yml#L6) file) can be manipulated as if the user was logged into the host machine. 
If you do not require this functionality, you may consider removing the socket mount from this file. 

## Configuring IPFS WebUI

To get the IPFS Web UI to work properly, you'll need to follow the directions on the startup page the first time you click on the 
IPFS service in the auth portal. It will ask you to run the following two commands in the IPFS container (with `example.com` 
replaced with your public URL):

```shell
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["https://example.com", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
```

To do this, open a terminal in the IDE and start an interactive session in the IPFS service container:

```shell
docker exec -ti ipfs_node /bin/sh
```

Once in the interactive shell, run the two commands from above. Now you must restart the IPFS service by running the following command
in a new terminal:

```shell
docker restart ipfs_node
```

## TODO:

1. Add alerts for Slack
2. Add GPU support
3. Make the login form prettier