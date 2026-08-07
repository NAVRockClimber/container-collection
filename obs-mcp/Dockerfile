ARG ALPINE_VERSION=3.24
ARG OBS_VERSION=0.7.1

FROM alpine:${ALPINE_VERSION} AS downloader
ARG TARGETARCH
ARG OBS_VERSION

RUN wget -qO /tmp/obs.tar.gz \
      "https://github.com/rhobs/obs-mcp/releases/download/v${OBS_VERSION}/obs-mcp_${OBS_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar xzf /tmp/obs.tar.gz -C /usr/local/bin obs-mcp \
    && chmod +x /usr/local/bin/obs-mcp

FROM alpine:${ALPINE_VERSION}
COPY --from=downloader /usr/local/bin/obs-mcp /usr/local/bin/obs-mcp
USER 65532:65532
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["wget", "-q", "-O", "/dev/null", "http://localhost:8080/"]
ENTRYPOINT ["/usr/local/bin/obs-mcp"]
CMD ["--listen", ":8080"]
