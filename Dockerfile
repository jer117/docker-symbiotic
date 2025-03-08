FROM golang:1.22-bullseye as builder

ARG VERSION=main

ENV PACKAGES make gcc g++ libc-dev git bash curl jq unzip

RUN apt-get update && apt-get install -y $PACKAGES

WORKDIR /

# Option 1 - clone repo and build oasys and rpc binaries
RUN git clone https://github.com/symbioticfi/cosmos-sdk && \
   cd cosmos-sdk && \
   git checkout $VERSION && \
   make build-sym

# Pull all binaries into a second stage deploy container
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y libgcc-s1 libstdc++6 ca-certificates tzdata

# Copy over binaries from the build-env
COPY --from=builder /cosmos-sdk/build/symd /usr/local/bin/

# Run Oasys geth client
ENTRYPOINT ["symd"]

