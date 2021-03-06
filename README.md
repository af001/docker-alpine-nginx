# docker-nginx-scratch
Create Nginx container w/ OpenSSL using Alpine and Scratch</br>
Approx 4.81 MB in size

## Build
```bash
docker image  build -t nginx-scratch .
```

## Build with custom PCRE, OPENSSL, ZLIB, NGINX versions
```bash
docker image  \
       build  \
       --build-arg NGNX_VERSION=1.19.4  \
       --build-arg PCRE_VERSION=8.44    \
       --build-arg OSSL_VERSION=1.1.1h  \
       --build-arg ZLIB_VERSION=1.2.11  \
       -t nginx-scratch .
```

## Run
```bash
docker run -d -p 80:80 nginx-scratch
```

## Mount logs to host
```bash
docker run -d -p 80:80 -v /tmp/logs/:/usr/local/nginx/logs/ nginx-scratch
```

## Mount custom files
```bash
docker run -p 80:80 -v $(pwd)/nginx.conf:/usr/local/nginx/conf/nginx.conf -v $(pwd)/index.html:/usr/share/nginx/html/index.html nginx-scratch
```
