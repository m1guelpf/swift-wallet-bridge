# ================================
# Build image
# ================================
FROM swift:5.10-jammy as builder
WORKDIR /build

COPY ./Package.* ./
RUN swift package resolve --skip-update \
    $([ -f ./Package.resolved ] && echo "--force-resolved-versions" || true)

COPY . .

RUN swift build -c release -Xswiftc -static-executable

WORKDIR /staging

RUN cp "/usr/libexec/swift/linux/swift-backtrace-static" ./
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/App" ./
RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\.resources$' -exec cp -Ra {} ./ \;

RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
FROM gcr.io/distroless/cc-debian10
WORKDIR /app

COPY --from=builder --chown=vapor:vapor /staging /app

ENV SWIFT_BACKTRACE=enable=yes,sanitize=yes,threads=all,images=all,interactive=no,swift-backtrace=./swift-backtrace-static

ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]

EXPOSE 8080
