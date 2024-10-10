FROM alpine AS builder

RUN VERSION=$(wget -S --spider https://codeberg.org/forgejo/forgejo/releases/latest 2>&1 | grep location: | cut -d'/' -f6) && \
    wget https://codeberg.org/forgejo/forgejo/releases/download/$VERSION/forgejo-${VERSION#v}-linux-amd64.xz -O - | xzcat > /forgejo && \
    apk add --no-cache git git-lfs && \
    echo "git:x:1000:1000:git:/var/lib/forgejo:" > /passwd && \
    echo "git:x:1000:" > /group

FROM scratch

COPY --from=builder /passwd /group /etc/
COPY --from=builder /usr/bin/git* /usr/bin/
COPY --from=builder /usr/libexec/git-core /usr/libexec/git-core
COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1 /lib/libz* /lib/
COPY --from=builder /usr/lib/libexpat* /usr/lib/libpcre2* /usr/lib/

USER 1000
ENV PATH=/usr/bin
WORKDIR /tmp
WORKDIR /var/lib/forgejo
COPY --from=builder --chmod=755 /forgejo /var/lib/forgejo/
ENTRYPOINT ["/var/lib/forgejo/forgejo"]
