#---
FROM docker.io/alpine:3.13 AS build

LABEL maintainer="Dave Baker <dbaker@redhat.com>"

RUN apk add --no-cache git g++ musl musl-dev bash gawk gzip make tar gmp mpfr4 mpfr-dev mpc1 mpc1-dev isl isl-dev http-parser-dev autoconf automake gcc make meson ninja openssl-dev jansson-dev zlib-dev patch

RUN git clone https://github.com/latchset/jose.git && cd jose && meson build && cd build && ninja && ninja install
RUN git clone https://github.com/latchset/tang.git
RUN cd tang && mkdir build && cd build && meson .. --prefix=/usr && ninja && ninja install


#---
FROM docker.io/alpine:3.13
COPY --from=build /usr/bin/jose /usr/bin/jose
COPY --from=build /usr/lib/libjose.so.0 /usr/lib/libjose.so.0
COPY --from=build /usr/lib/libjose.so.0.0.0 /usr/lib/libjose.so.0.0.0

COPY --from=build /usr/libexec/tangd /usr/libexec/tangd
COPY --from=build /usr/libexec/tangd-keygen /usr/libexec/tangd-keygen
COPY --from=build /usr/libexec/tangd-rotate-keys /usr/libexec/tangd-rotate-keys

RUN apk add --no-cache bash socat http-parser jansson zlib openssl curl
EXPOSE 8080

USER 1000

COPY start.sh /
CMD ["/start.sh"]


