FROM alpine:latest as build

#Define build argument for version
ARG VERSION=1.19.1

# Install build tools, libraries and utilities 
RUN apk add --no-cache --virtual .build-deps                                        \
        build-base                                                                  \   
        gnupg                                                                       \
        perl									    \
        linux-headers								    \
        pcre-dev                                                                    \
        wget                                                                        


COPY pcre-8.44.tar.gz /tmp/

# Retrieve and unpack pcre, zlib, and openssl    
RUN cd /tmp/									    && \
    wget -q http://www.openssl.org/source/openssl-1.1.1g.tar.gz			    && \
    tar -zxf openssl-1.1.1g.tar.gz					            && \
    cd openssl-1.1.1g								    && \
    ./Configure linux-x86_64 --prefix=/usr	                                    && \
    make         							            && \
    make install							

RUN cd /tmp/                                                                        && \
    tar -zxf pcre-8.44.tar.gz                                                       && \
    cd pcre-8.44                                                                    && \
    ./configure                                                                     && \
    make                                                                            && \
    make install                                                                    

RUN cd /tmp/                                                                        && \
    wget -q http://zlib.net/zlib-1.2.11.tar.gz                                         && \
    tar -zxf zlib-1.2.11.tar.gz                                                     && \
    cd zlib-1.2.11                                                                  && \
    ./configure                                                                     && \
    make                                                                            && \
    make install

# Retrieve, verify and unpack Nginx source - key server pgp.mit.edu  
RUN set -x									&&  \
    cd /tmp/                                                                    &&  \
    wget -q https://nginx.org/download/nginx-${VERSION}.tar.gz		        &&  \
    tar xzf nginx-${VERSION}.tar.gz					        &&  \
    echo ${VERSION}                                           

WORKDIR /tmp/nginx-${VERSION}

# Build and install nginx
RUN ./configure                                                                     \
        --with-ld-opt="-static"                                                     \
        --with-pcre="/tmp/pcre-8.44"                                                \
        --with-zlib="/tmp/zlib-1.2.11"                                              \
        --with-http_ssl_module                                                  &&  \   

    make install                                                                &&  \
    strip /usr/local/nginx/sbin/nginx

# Symlink access and error logs to /dev/stdout and /dev/stderr, in 
# order to make use of Docker's logging mechanism
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log                         &&  \
    ln -sf /dev/stderr /usr/local/nginx/logs/error.log

FROM scratch 

# Customise static content, and configuration
COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY index.html /usr/share/nginx/html/
COPY nginx.conf /usr/local/nginx/conf/

#Change default stop signal from SIGTERM to SIGQUIT
STOPSIGNAL SIGQUIT

# Expose port
EXPOSE 80

# Define entrypoint and default parameters 
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
