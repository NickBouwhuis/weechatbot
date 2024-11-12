FROM debian:bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Install required packages
RUN apt-get update && apt-get install -y \
    tmux \
    weechat \
    python3 \
    python3-pip \
    python3-psycopg2 \
    python3-pycurl \
    python3-iso3166 \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create weechat user and set up directory structure
RUN useradd -m -d /home/weechat weechat
WORKDIR /home/weechat

# Create necessary directories
RUN mkdir -p /home/weechat/.weechat/python/autoload \
    && mkdir -p /home/weechat/.weechat/python/wcb_bot/modules \
    && mkdir -p /home/weechat/.weechat/python/wcb_bot/extra_modules \
    && chown -R weechat:weechat /home/weechat/.weechat

# Copy WeeChatBot files
COPY --chown=weechat:weechat . /home/weechat/weechatbot/
RUN cp /home/weechat/weechatbot/wcb.py /home/weechat/.weechat/python/ \
    && cp -r /home/weechat/weechatbot/wcb_bot /home/weechat/.weechat/python/ \
    && ln -sf /home/weechat/.weechat/python/wcb.py /home/weechat/.weechat/python/autoload/wcb.py

# Copy config file
COPY --chown=weechat:weechat wcb_config.json /home/weechat/.weechat/python/wcb_bot/

# Copy and set up startup script
COPY --chown=weechat:weechat docker-entrypoint.sh /home/weechat/
RUN chmod +x /home/weechat/docker-entrypoint.sh

USER weechat

# Use startup script instead of direct WeeChat command
CMD ["/home/weechat/docker-entrypoint.sh"]
