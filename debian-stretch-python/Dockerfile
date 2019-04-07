FROM antwal/debian-stretch-minimal:latest

MAINTAINER Walter Antolini <antwal@gmail.com>

COPY setup/ /usr/local/debian-base-setup/

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ARG version
ARG keyserver
# Default version is 3.5.6 on build
ENV PYTHON_VERSION=${version:-"3.5.6"}
ENV KEY_SERVER=${keyserver:-"ipv4.pool.sks-keyservers.net"}

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 18.1

ENV DEBIAN_FRONTEND noninteractive
RUN /usr/local/debian-base-setup/020-debian-base-python

CMD ["/usr/local/bin/boot-debian-base"]
