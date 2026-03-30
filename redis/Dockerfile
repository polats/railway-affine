FROM redis:7-alpine

ENV PORT=6379

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
  CMD redis-cli --raw incr ping || exit 1
