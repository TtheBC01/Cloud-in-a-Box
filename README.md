# Browser IDE

This repo uses the open-source [Theia](https://theia-ide.org/) framework to build a browser-based IDE, similar to VSCode, that
can be served from Docker container and used as an alternative to traditional RDP tools, particularly 
when coupled with an [authentication layer](https://github.com/greenpau/caddy-auth-portal) and an 
[introspective tunnel](https://www.cloudflare.com/products/tunnel/) technology. 

## Requirments

Do build this project you need the [Docker Engine](https://docs.docker.com/get-docker/) available on your machine.

## Building

To build the IDE environment, use the Docker cli:

```
docker build -t browser-ide .
```

Once built, you can run it locally by exposing port `8080` on the ide container:

```
docker run -p 8080:8080 --rm --name browser-ide -d browser-ide
```

## Pre-built Docker Image

A pre-built version of the browser-ide can be pulled from Docker Hub:

```
docker pull tthebc01/browser-ide
docker run -p 8080:8080 --rm --name browser-ide -d tthebc01/browser-ide:latest
```
