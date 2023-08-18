FROM debian:latest

RUN apt-get update && apt-get install -y libfftw3-dev  \
 build-essential git libsamplerate0-dev direwolf cmake gettext \
 && rm -rf /var/lib/apt/lists/*

# spy server
RUN git clone https://github.com/miweber67/spyserver_client.git && cd spyserver_client && make && cp ss_client /usr/bin/ss_iq
#csdr
RUN cd / && git clone https://github.com/jketterl/csdr.git && cd csdr && git checkout master && mkdir -p build && cd build && cmake .. && make && make install && ldconfig

# Copy direwolf config template
COPY direwolf.conf.tpl /root/direwolf.conf.tpl

# startup script
COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENTRYPOINT ["/bin/sh", "-c", "/run.sh"]