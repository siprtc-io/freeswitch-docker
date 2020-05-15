FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y wget curl git

RUN wget -O - https://files.freeswitch.org/repo/ubuntu-1604/freeswitch-1.6/freeswitch_archive_g0.pub | apt-key add -

RUN echo "deb http://files.freeswitch.org/repo/ubuntu-1604/freeswitch-1.6/ xenial main" > /etc/apt/sources.list.d/freeswitch.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1FDDF413C2B201E5

RUN apt-get update -y

RUN apt-get install -y git libavresample-dev curl nano screen subversion build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev libtool libtool-bin libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.2-dev libopus-dev cmake libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev python-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1-dev libavformat-dev libswscale-dev
 
RUN apt-get update
  
RUN cd /usr/local/src && git clone --single-branch --branch v1.10.3 https://github.com/signalwire/freeswitch.git 

COPY modules.conf /usr/local/src/freeswitch

RUN apt-get -y install libshout3-dev libmp3lame-dev libmpg123-dev libpng12-dev

RUN cd /usr/local/src/freeswitch && ./bootstrap.sh -j && ./configure -C && make && make install

COPY modules.conf /usr/local/src/freeswitch

COPY entrypoint.sh /home/entrypoint.sh

RUN rm -Rf /usr/local/freeswitch/conf/dialplan/*

RUN rm /usr/local/freeswitch/conf/sip_profiles/external-ipv6.xml && rm /usr/local/freeswitch/conf/sip_profiles/internal-ipv6.xml && rm /usr/local/freeswitch/conf/sip_profiles/external-ipv6/*; exit 0

COPY conf /usr/local/freeswitch/conf

RUN ln -s /usr/local/freeswitch/bin/freeswitch /usr/local/bin/

RUN ln -s /usr/local/freeswitch/bin/fs_cli /usr/local/bin

RUN chmod 755 /home/entrypoint.sh && \
        chown root:root /home/entrypoint.sh

ENTRYPOINT ["/home/entrypoint.sh"]
