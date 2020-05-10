FROM debian:buster

RUN apt-get update && apt-get install -yq git gnupg2 wget lsb-release

RUN wget -O - https://files.freeswitch.org/repo/deb/debian-release/fsstretch-archive-keyring.asc | apt-key add -

RUN echo "deb http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list

RUN echo "deb-src http://files.freeswitch.org/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list

RUN apt-get update

RUN apt-get -yq build-dep freeswitch

WORKDIR /usr/local/src

RUN git clone https://github.com/signalwire/freeswitch.git -bv1.10 freeswitch

WORKDIR /usr/local/src/freeswitch

RUN ./bootstrap.sh -j && ./configure && make && make install
