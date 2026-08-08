ARG ALPINE_VERSION=3.24
ARG UPSTREAM_REPO=rhobs/obs-mcp
ARG UPSTREAM_VERSION=0.7.1
ARG EXPOSE_PORT=8080

FROM alpine:${ALPINE_VERSION} AS downloader
ARG TARGETARCH
ARG UPSTREAM_REPO
ARG UPSTREAM_VERSION

RUN wget -qO /tmp/obs.tar.gz \
      "https://github.com/${UPSTREAM_REPO}/releases/download/v${UPSTREAM_VERSION}/obs-mcp_${UPSTREAM_VERSION}_linux_${TARGETARCH}.tar.gz" \
    && tar xzf /tmp/obs.tar.gz -C /usr/local/bin obs-mcp \
    && chmod +x /usr/local/bin/obs-mcp

FROM alpine:${ALPINE_VERSION}
COPY --from=downloader /usr/local/bin/obs-mcp /usr/local/bin/obs-mcp
USER 65532:65532
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["wget", "-q", "-O", "/dev/null", "--post-data={\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"ping\"}", "--header=Content-Type: application/json", "http://localhost:8080/mcp"]
ENTRYPOINT ["/usr/local/bin/obs-mcp"]
CMD ["--listen", ":8080"]
