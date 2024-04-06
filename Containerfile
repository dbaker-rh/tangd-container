#---
FROM docker.io/alpine:3.19 AS build
LABEL maintainer="Dave Baker <dbaker@redhat.com>"

RUN apk add --no-cache git g++ bash gawk gzip make tar autoconf automake gcc meson ninja   \
                       musl-dev gmp mpfr-dev mpc1-dev isl-dev http-parser-dev openssl-dev jansson-dev zlib-dev

RUN git clone https://github.com/latchset/jose.git && cd jose && meson build && cd build && ninja && ninja install
RUN git clone https://github.com/latchset/tang.git
RUN cd tang && mkdir build && cd build && \
       meson .. --prefix=/usr          && \
       ninja && ninja install


#---
FROM docker.io/alpine:3.19
LABEL maintainer="Dave Baker <dbaker@redhat.com>"

RUN apk add --no-cache bash socat http-parser jansson zlib openssl curl busybox-extras

# Copy files from build container
COPY --from=build /usr/bin/jose /usr/bin/jose
COPY --from=build /usr/lib/libjose.so.0 /usr/lib/libjose.so.0
COPY --from=build /usr/lib/libjose.so.0.0.0 /usr/lib/libjose.so.0.0.0

COPY --from=build /usr/libexec/tangd /usr/libexec/tangd
COPY --from=build /usr/libexec/tangd-keygen /usr/libexec/tangd-keygen
COPY --from=build /usr/libexec/tangd-rotate-keys /usr/libexec/tangd-rotate-keys

# Squelch warning on signal trap
RUN sed -i -e '/^trap/ { s/^/#/; }' /usr/libexec/tangd-keygen

EXPOSE 7500

# Run as non-root
USER 1000

COPY start.sh /
CMD ["/start.sh"]


