FROM eclipsefdn/nginx:stable-alpine

COPY pages/* /usr/share/nginx/html/pages/
# Using embedded images and css instead
#COPY resources/* /usr/share/nginx/html/pages/resources/

COPY maintenance.nginx.conf /etc/nginx/conf.d/default.conf