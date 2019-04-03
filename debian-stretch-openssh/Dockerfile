FROM antwal/debian-stretch-minimal:latest

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/
COPY scripts /usr/local/bin

ENV DEBIAN_FRONTEND noninteractive
RUN /usr/local/debian-base-setup/020-debian-base-openssh

COPY preinit/ /usr/local/preinit/

EXPOSE 22

CMD ["/usr/local/bin/boot-debian-base"]
