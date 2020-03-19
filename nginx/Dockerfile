
FROM nginx:1.15.5-alpine

RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/nginx.conf

COPY wait-for /usr/local/bin/wait-for
RUN chown root:root /usr/local/bin/wait-for && \
    chmod 755 /usr/local/bin/wait-for

RUN apk add --no-cache gettext

ENTRYPOINT [ "/entrypoint.sh" ]
COPY entrypoint.sh /entrypoint.sh
