ARG UPSTREAM_IMAGE
ARG UPSTREAM_TAG_SHA

FROM ${UPSTREAM_IMAGE}:${UPSTREAM_TAG_SHA}
EXPOSE 5030 5031
ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} WEBUI_PORTS="5030/tcp,5031/tcp"

RUN apk add --no-cache icu-libs

ARG VERSION_URL_ARM64
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" -H "Authorization: Bearer ${GITHUB_TOKEN}" "${VERSION_URL_ARM64}" && unzip -q "${zipfile}" -d "${APP_DIR}" && rm "${zipfile}" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    chmod +x "${APP_DIR}/slskd"

COPY root/ /
RUN find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +
