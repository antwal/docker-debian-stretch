# Docker container images with "headless" VNC session

This repository contains a collection of Docker images with headless VNC environments.

Each Docker image is installed with the following components:

* Desktop environment [**Xvfb**](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
* VNC-Server (default VNC port `5901`)
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client (default http port `6901`)
