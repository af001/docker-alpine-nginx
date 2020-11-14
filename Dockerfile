FROM alpine:latest as build

#Define build argument for version
ARG NGNX_VERSION=1.19.4
ARG PCRE_VERSION=8.44
ARG OSSL_VERSION=1.1.1h
ARG ZLIB_VERSION=1.2.11

# Set working directory
WORKDIR /tmp

# Install build tools, libraries and utilities 
RUN apk add --no-cache --virtual .build-deps                                \
        build-base                                                          \   
        gnupg                                                               \
        perl                                                                \
        linux-headers                                                       \
        pcre-dev                                                            \
        wget                                                                \                                                                
        geoip-dev								    	  

# Download and unpack packages using wget and tar
RUN wget -q https://www.openssl.org/source/openssl-$OSSL_VERSION.tar.gz     && \
    tar -xzf openssl-$OSSL_VERSION.tar.gz                                   && \
    wget -q https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.bz2        && \
    tar -xjf pcre-$PCRE_VERSION.tar.bz2                                     && \
    wget -q http://zlib.net/zlib-$ZLIB_VERSION.tar.gz                       && \
    tar -xzf zlib-$ZLIB_VERSION.tar.gz                                      && \
    wget -q http://nginx.org/download/nginx-$NGNX_VERSION.tar.gz            && \
    tar -xzf nginx-$NGNX_VERSION.tar.gz
					
# Install Nginx with PCRE, OpenSSL, Geomod, Zlib
RUN set -x                                                                  && \
    cd /tmp/nginx-$NGNX_VERSION                                             && \
    ./configure                                                             \
        --with-ld-opt="-static"                                             \
        --with-pcre=/tmp/pcre-${PCRE_VERSION}                               \
        --with-zlib=/tmp/zlib-${ZLIB_VERSION}                               \
        --with-openssl=/tmp/openssl-${OSSL_VERSION}                         \
        --with-http_realip_module                                           \
        --with-http_geoip_module                                            \
        --with-http_ssl_module                                              && \   
    make                                                                    && \
    make Install                                                            && \
    strip /usr/local/nginx/sbin/nginx

# Symlink access and error logs to /dev/stdout and /dev/stderr, in 
# order to make use of Docker's logging mechanism
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log                     && \
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
