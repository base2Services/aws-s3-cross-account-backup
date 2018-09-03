FROM python:3.7-alpine3.8

RUN apk add --update \
      bash \
      jq \
    && rm -rf /var/cache/apk/* \
    && pip install awscli

COPY backup.sh /backup.sh

RUN chmod u+x /backup.sh

CMD ["/backup.sh"]
