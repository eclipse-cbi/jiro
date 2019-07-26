FROM eclipsefdn/nginx:stable-alpine

COPY pages/* /usr/share/nginx/html/pages/

COPY maintenance.nginx.conf /etc/nginx/conf.d/default.conf