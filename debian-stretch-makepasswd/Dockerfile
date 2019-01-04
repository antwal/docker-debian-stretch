FROM antwal/debian-stretch-minimal:latest

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/

ENV DEBIAN_FRONTEND noninteractive
RUN /usr/local/debian-base-setup/011-debian-base-makepasswd

ENTRYPOINT ["makepasswd"]
