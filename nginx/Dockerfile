FROM nginx:1.15.5-alpine

RUN apk add --no-cache curl

RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/nginx.conf
