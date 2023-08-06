FROM alpine:latest

ARG VERSION=7.76

RUN \
    # Install required packages
    apk --update --upgrade add \
      bash \
      fluxbox \
      git \
      supervisor \
      xvfb \
      x11vnc \
      openjdk8-jre \
      curl \
      unzip \
      && \
    # Install noVNC
    git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git && \
    rm -rf /root/noVNC/utils/websockify/.git && \
    apk del git && \
    ln -s /root/noVNC/vnc.html /root/noVNC/index.html

ARG DOWNLOAD_URL=https://github.com/tonikelope/megabasterd/releases/download/v${VERSION}/MegaBasterdLINUX_${VERSION}_portable.zip

RUN \
    mkdir /output && \
    cd /tmp && \
    curl -# -L -o MegaBasterd.zip ${DOWNLOAD_URL} && \
    unzip -q MegaBasterd.zip && \
    mv MegaBasterdLINUX/jar/MegaBasterd.jar /root/. && \
    # Cleanup.
    apk del curl unzip && \
    rm -rf /tmp/* /tmp/.[!.]*


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8080

# Setup environment variables
ENV HOME=/root \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
