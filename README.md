# docker-nginx-scratch
Create Nginx container w/ OpenSSL using Alpine and Scratch</br>
Approx 4.5 MB in size

## Build
docker image  build -t nginx-scratch .

## Run
docker run -d -p 80:80 nginx-scratch

## Mount custom files
docker run -p 80:80 -v $(pwd)/nginx.conf:/usr/local/nginx/conf/nginx.conf -v $(pwd)/index.html:/usr/share/nginx/html/index.html nginx-scratch
