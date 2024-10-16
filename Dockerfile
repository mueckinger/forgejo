# FROM alpine AS builder
FROM alpine

RUN VERSION=$(wget -S --spider https://codeberg.org/forgejo/forgejo/releases/latest 2>&1 | grep location: | cut -d'/' -f6) && \
    # wget https://codeberg.org/forgejo/forgejo/releases/download/$VERSION/forgejo-${VERSION#v}-linux-amd64.xz -O - | xzcat > /forgejo && \
    mkdir -p /var/lib/forgejo && \
    wget https://codeberg.org/forgejo/forgejo/releases/download/$VERSION/forgejo-${VERSION#v}-linux-amd64.xz -O - | xzcat > /var/lib/forgejo/forgejo && \
    chmod 755 /var/lib/forgejo/forgejo && \
    apk add --no-cache git git-lfs bash && \
    echo "git:x:1000:1000:git:/var/lib/forgejo:" > /passwd && \
    echo "git:x:1000:" > /group

# FROM scratch

# COPY --from=builder /passwd /group /etc/bash /etc/gitconfig /etc/inputrc /etc/shells /etc/profile.d /etc/terminfo /etc/
# COPY --from=builder /bin/bash /bin/
# COPY --from=builder /usr/bin/git* /usr/bin/
# COPY --from=builder /usr/libexec/git-core /usr/libexec/
# COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/libc.musl-x86_64.so.1 /lib/libz* /lib/
# COPY --from=builder /usr/lib /usr/lib
# COPY --from=builder /usr/share/git-core /usr/share/

USER 1000
# ENV PATH=/bin:/usr/bin
# WORKDIR /tmp
WORKDIR /var/lib/forgejo
# COPY --from=builder --chmod=755 /forgejo /var/lib/forgejo/
ENTRYPOINT ["/var/lib/forgejo/forgejo"]
