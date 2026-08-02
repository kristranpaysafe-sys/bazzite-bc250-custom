FROM ghcr.io/projectbluefin/common:latest@sha256:df2fa93dac84cda91d568bd694e5051abbbdba37bf3d54a6cc15cdc80e645e2c AS common
FROM ghcr.io/ublue-os/brew:latest@sha256:5c5b6dea4b9faaab4d6fa81d7fc4f37f218c8a75a0839c72ae70b268bfdf4b0f AS brew 

FROM scratch AS ctx
COPY build /build
COPY custom /custom
COPY --from=common /system_files /oci/common
COPY --from=brew /system_files /oci/brew 

FROM ghcr.io/ublue-os/bazzite:stable 

ARG IMAGE_NAME="bazzite-bc250-custom"
ARG IMAGE_VENDOR="projectbluefin"
ARG UBLUE_IMAGE_TAG="stable"
ARG BASE_IMAGE_NAME="bazzite"
ARG FEDORA_MAJOR_VERSION="44"
ARG VERSION="" 

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=tmpfs,dst=/boot --mount=type=tmpfs,dst=/tmp /ctx/build/00-image-info.sh 

RUN dnf5 config-manager setopt keepcache=1 install_weak_deps=0 

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache/libdnf5 --mount=type=cache,dst=/var/cache/rpm-ostree --mount=type=secret,id=GITHUB_TOKEN --mount=type=tmpfs,dst=/boot --mount=type=tmpfs,dst=/tmp /ctx/build/10-build.sh 

RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/boot /ctx/build/clean-stage.sh 

RUN rm -rf /opt && ln -s /var/opt /opt 

CMD ["/sbin/init"] 

RUN bootc container lint --fatal-warnings
