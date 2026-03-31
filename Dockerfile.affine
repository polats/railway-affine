FROM ghcr.io/toeverything/affine:stable

ENV PORT=3010
ENV NODE_ENV=production
ENV AFFINE_SERVER_PORT=3010
ENV AFFINE_INDEXER_ENABLED=false
ENV REDIS_SERVER_PORT=6379

COPY configure-copilot.sh /usr/local/bin/configure-copilot.sh
COPY configure-dns.sh /usr/local/bin/configure-dns.sh
RUN chmod +x /usr/local/bin/configure-copilot.sh /usr/local/bin/configure-dns.sh

EXPOSE 3010
