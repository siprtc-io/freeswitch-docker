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
