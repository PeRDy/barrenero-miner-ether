FROM nvidia/cuda:9.1-devel
LABEL maintainer="José Antonio Perdiguero López <perdy.hh@gmail.com>"

ENV APP=barrenero-miner-ether

# Install locales
RUN apt-get update && \
    apt-get install -y locales locales-all
ENV LANG='es_ES.UTF-8' LANGUAGE='es_ES.UTF-8:es' LC_ALL='es_ES.UTF-8' PYTHONIOENCODING='utf-8'

# Install build requirements
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libidn11-dev \
        apt-transport-https \
        software-properties-common\
        git \
        curl \
        cmake && \
    apt-get clean && \
    rm -rf /tmp/* \
        /etc/apt/sources.list.d/passenger.list \
        /var/tmp/* \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/*.deb \
        /var/cache/apt/archives/partial/*.deb \
        /var/cache/apt/*.bin

RUN add-apt-repository -y ppa:jonathonf/python-3.6 && \
    apt-get update && \
    apt-get install -y python3.6 python3-pip && \
    apt-get clean && \
    rm -rf /tmp/* \
        /etc/apt/sources.list.d/passenger.list \
        /var/tmp/* \
        /var/lib/apt/lists/* \
        /var/cache/apt/archives/*.deb \
        /var/cache/apt/archives/partial/*.deb \
        /var/cache/apt/*.bin

# Install ethminer
RUN git clone https://github.com/ethereum-mining/ethminer /srv/apps/ethminer
WORKDIR /srv/apps/ethminer
RUN mkdir build; cd build && \
    cmake .. -DETHASHCUDA=ON -DETHASHCL=OFF && \
    cmake --build . && \
    make install && \
    rm -rf /srv/apps/ethminer

# Create project dirs
RUN mkdir -p /srv/apps/$APP/logs
WORKDIR /srv/apps/$APP

# Install pip requirements
COPY requirements.txt constraints.txt /srv/apps/$APP/
RUN python3.6 -m pip install --upgrade pip && \
    python3.6 -m pip install --no-cache-dir -r requirements.txt -c constraints.txt && \
    rm -rf $HOME/.cache/pip/*

# Copy application
COPY . /srv/apps/$APP/

ENTRYPOINT ["./run"]