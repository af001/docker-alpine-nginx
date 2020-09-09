# docker-nginx-scratch
Create Nginx container w/ OpenSSL using Alpine and Scratch</br>
Approx 4.5 MB in size

## Build
docker image  build -t nginx-scratch .
## Run
docker run -d -p 80:80 nginx-scratch
