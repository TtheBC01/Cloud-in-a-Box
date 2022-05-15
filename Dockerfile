FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
    && apt install -y software-properties-common gpg \ 
    && add-apt-repository -y ppa:deadsnakes/ppa \
	&& apt update -y \
    && apt install -y vim \
                   git \
                   curl \
                   gcc \
                   g++ \ 
                   make \ 
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

RUN mkdir /.browser-ide
WORKDIR /.browser-ide
COPY . .

RUN yarn
RUN yarn build

ENTRYPOINT ["yarn", "start", "--hostname", "0.0.0.0", "--port", "8080"]