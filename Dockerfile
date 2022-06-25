# See https://caddyserver.com/docs/ for info on Caddy Server
FROM caddy:builder as caddy-build

RUN xcaddy build \
    --with github.com/greenpau/caddy-security \
    --with github.com/greenpau/caddy-trace

FROM ubuntu:18.04

# deadsnakes asks for your region, so we need to tell it to be non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# install dependencies for Theia IDE
RUN apt update -y \
    && apt install -y software-properties-common gpg \ 
    && add-apt-repository -y ppa:deadsnakes/ppa \
	&& apt update -y \
    && apt install -y vim \
                   tmux \
                   git \
                   curl \
                   gcc \
                   g++ \ 
                   make \ 
                   docker.io \
                   libsecret-1-dev \
                   libx11-dev \
                   libxkbfile-dev \
                   supervisor \
                   python3.9 \ 
                   python3-pip \
                   python3.9-dev \
    && curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt install -y nodejs \
    && npm install --global yarn

# IDE will live in the .browser-ide directory
RUN mkdir /.browser-ide
WORKDIR /.browser-ide

# Build the IDE
COPY package.json .
COPY ./browser-ide/preloadTemplate.html preloadTemplate.html
RUN yarn
RUN yarn build

# Get the caddy server executable with auth plugin enabled
COPY --from=caddy-build /usr/bin/caddy /usr/bin/caddy

# Get auxiliary files for Caddy server and process manager
COPY ./browser-ide/supervisor.conf /etc/
COPY ./browser-ide/Caddyfile /etc/

# Set some environment variables for the IDE
ENV THEIA_MINI_BROWSER_HOST_PATTERN={{hostname}}
ENV THEIA_WEBVIEW_EXTERNAL_ENDPOINT={{hostname}}
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/.browser-ide/plugins

# add a non-root user if you want
# RUN useradd -ms /bin/bash myuser
# USER myuser

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor.conf"]