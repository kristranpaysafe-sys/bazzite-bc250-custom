# Execute the custom UGREEN CM748 hardware driver patch installation
RUN --mount=type=bind,from=ctx,source=/,target=/ctx --mount=type=cache,dst=/var/cache/libdnf5 --mount=type=cache,dst=/var/cache/rpm-ostree --mount=type=tmpfs,dst=/boot --mount=type=tmpfs,dst=/tmp /ctx/build/install-cm748-patch.sh
