FROM antwal/debian-stretch-minimal

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/
COPY files/ /usr/local/debian-base-setup/files/
COPY scripts /usr/local/bin

RUN /usr/local/debian-base-setup/020-debian-base-openssh

COPY preinit/ /usr/local/preinit/

EXPOSE 22

CMD ["/usr/local/bin/boot-debian-base"]
