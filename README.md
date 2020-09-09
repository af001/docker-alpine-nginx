# docker-nginx-scratch
Create new Nginx Server w/ OpenSSL included from Scratch 
Approx 4.5 MB in size

## Build
docker image  build -t nginx-scratch .
## Run
docker run -d -p 80:80 nginx-local
