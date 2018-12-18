FROM antwal/debian-stretch-minimal

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/

# TODO: Add custom script for generate custom password

RUN /usr/local/debian-base-setup/011-debian-base-makepasswd

ENTRYPOINT ["makepasswd"]
