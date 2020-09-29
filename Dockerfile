FROM	alpine:3.12 as build

MAINTAINER Jens <arrkiin@gmail.com>

ENV JO_VERSION 1.3
ENV PANDOC_VERSION 2.10.1

WORKDIR /tmp

RUN set -x && \
    apk add --update --no-cache --virtual build-deps\
    build-base \
    autoconf \
    automake \
    pkgconf \
    curl

RUN set -x && \
    curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz --output pandoc-${PANDOC_VERSION}.tar.gz && \
    tar xf pandoc-${PANDOC_VERSION}.tar.gz && \
    cd pandoc-${PANDOC_VERSION} && \
    cp -R * /usr/local && \
    cd .. && \
    rm pandoc-${PANDOC_VERSION}.tar.gz && \
    rm -Rf pandoc-${PANDOC_VERSION}

RUN set -x && \
    curl -L https://github.com/jpmens/jo/releases/download/${JO_VERSION}/jo-${JO_VERSION}.tar.gz --output jo-$JO_VERSION.tar.gz && \
    tar xf jo-${JO_VERSION}.tar.gz && \
    cd jo-${JO_VERSION} && \
    autoreconf -i && \
    ./configure --prefix=/usr/local/jo && \
    make check && \
    make install && \
    apk del --purge build-deps && \
    cd .. && \
    rm -Rf jo-${JO_VERSION} && \
    rm jo-${JO_VERSION}.tar.gz

FROM alpine:3.12

COPY --from=build /usr/local/jo /usr/local

ENTRYPOINT ["/usr/local/bin/jo"]
