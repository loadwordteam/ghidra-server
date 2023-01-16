# loadwordteam/ghidra-server
ARG ghidra_install_path=/opt/ghidra

# We need an OpenJDK17 image NOT based on alpine (or anything with
# musl libc), this server has problems even with the ARM JVM, let's
# use a very boring flavour.
FROM debian:bullseye-slim AS builder

ARG ghidra_install_path
ARG ghidra_url=https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2.2_build/ghidra_10.2.2_PUBLIC_20221115.zip
ARG ghidra_sha256=feb8a795696b406ad075e2c554c80c7ee7dd55f0952458f694ea1a918aa20ee3
ARG ghidra_version=10.2.2_PUBLIC
ARG ghidra_repo_path=/srv/repositories

ENV LANG=C.UTF-8 \
    GHIDRA_HOME=${ghidra_install_path} \
    GHIDRA_REPO_DIR=${ghidra_repo_path}

ADD $ghidra_url ghidra.zip

RUN apt -qq update \
    && apt -y install \
        locales \
        gettext-base \ 
        ncat \
        openjdk-17-jre-headless \
        unzip \
    && echo "${ghidra_sha256} ghidra.zip" | sha256sum -c \
    && unzip -qo ghidra.zip \
    && rm ghidra.zip \
    && mkdir -p /opt \
    && mv "ghidra_${ghidra_version}" "${ghidra_install_path}" \
    && rm "${ghidra_install_path}/server/server.conf" \
    && rm -rf /var/lib/apt/lists/* \
    # Set timezone to UTC by default
    && ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    # Use unicode
    && locale-gen C.UTF-8 || true

WORKDIR "${ghidra_install_path}/server"
COPY ./server.conf.tmpl /
COPY entrypoint.sh /

EXPOSE 13100 13101 13102

ENTRYPOINT ["/entrypoint.sh"]
CMD ["./ghidraSvr", "console"]

