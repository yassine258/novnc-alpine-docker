FROM alpine:edge

RUN \
    # Install required packages
    echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update --upgrade add \
      bash \
      fluxbox \
      git \
      supervisor \
      xvfb \
      x11vnc \
      && \
    # Install noVNC
    git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git && \
    rm -rf /root/noVNC/utils/websockify/.git && \
    apk del git && \
    sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/novnc_proxy

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

RUN \
    # Install xterm
    apk add xterm && \
    # Append xterm entry to supervisord.conf
    cd /etc/supervisor/conf.d && \
    echo '[program:xterm]' >> supervisord.conf && \
    echo 'command=xterm' >> supervisord.conf && \
    echo 'autorestart=true' >> supervisord.conf
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
