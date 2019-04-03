FROM antwal/debian-stretch-minimal:latest

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/
COPY files/ /usr/local/debian-base-setup/files/

ENV DEBIAN_FRONTEND noninteractive
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
RUN /usr/local/debian-base-setup/020-debian-base-nodevnc

ENV TERM=xterm \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1600 \
    SCREEN_HEIGHT=900 \
    SCREEN_DEPTH=24+32

COPY preinit /usr/local/preinit

EXPOSE 5900 6900

CMD ["/usr/local/bin/boot-debian-base"]
