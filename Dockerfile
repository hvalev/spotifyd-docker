# An extra layer to get around this bug https://github.com/docker/buildx/issues/395
# It's there simply to download and add required libraries for cargo build
FROM --platform=$BUILDPLATFORM rust:1.86.0-bookworm AS rust_fix

# standard version
ARG VERSION=v0.4.1
ENV USER=root
ENV V_SPOTIFYD=${VERSION}

WORKDIR /usr/src/spotifyd
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y apt-transport-https ca-certificates git && \
    git clone --depth 1 https://github.com/Spotifyd/spotifyd.git . && \
    git checkout -b ${V_SPOTIFYD}

# Don't do `cargo init` or --> error: `cargo init` cannot be run on existing Cargo packages
# RUN cargo init
RUN mkdir -p .cargo \
  && cargo vendor > .cargo/config

###
# Base build image building the barebones spotifyd client which is alsa
###
FROM rust:1.86.0-bookworm AS alsa-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev cmake libclang-dev clang
COPY --from=rust_fix /usr/src/spotifyd /usr/src/spotifyd
WORKDIR /usr/src/spotifyd
RUN cargo build -j 2 --release --offline

###
# Build image for alsa-dbus
###
FROM alsa-build AS alsa-dbus-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev libdbus-1-dev
RUN cargo build -j 2 --release --features dbus_mpris --offline

###
# Build image for pulseaudio
###
FROM alsa-build AS pulseaudio-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev build-essential pulseaudio libpulse-dev
RUN cargo build -j 2 --release --features pulseaudio_backend --offline

###
# Build image for pulseaudio-dbus
###
FROM pulseaudio-build AS pulseaudio-dbus-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev build-essential pulseaudio libpulse-dev libdbus-1-dev
RUN cargo build -j 2 --release --features pulseaudio_backend,dbus_mpris --offline

###
# Build image for portaudio
###
FROM alsa-build AS portaudio-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev build-essential pulseaudio libpulse-dev
RUN cargo build -j 2 --release --features pulseaudio_backend --offline

###
# Build image for portaudio-dbus
###
FROM portaudio-build AS portaudio-dbus-build
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y libasound2-dev build-essential pulseaudio libpulse-dev libdbus-1-dev
RUN cargo build -j 2 --release --features pulseaudio_backend,dbus_mpris --offline

###
# Release image for alsa
###
FROM debian:bookworm-20250407-slim AS alsa-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=alsa-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["/usr/bin/spotifyd", "--no-daemon"]
USER spotify

###
# Release image for alsa-dbus
###
FROM debian:bookworm-20250407-slim AS alsa-dbus-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 dbus libssl3 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=alsa-dbus-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["dbus-run-session", "/usr/bin/spotifyd", "--no-daemon"]
USER spotify

###
# Release image for pulseaudio
###
FROM debian:bookworm-20250407-slim AS pulseaudio-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 pulseaudio && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=pulseaudio-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["/usr/bin/spotifyd", "--no-daemon"]
USER spotify

###
# Release image for pulseaudio-dbus
###
FROM debian:bookworm-20250407-slim AS pulseaudio-dbus-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 pulseaudio dbus libssl3 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=pulseaudio-dbus-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["dbus-run-session", "/usr/bin/spotifyd", "--no-daemon"]
USER spotify

###
# Release image for portaudio
###
FROM debian:bookworm-20250407-slim AS portaudio-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=portaudio-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["/usr/bin/spotifyd", "--no-daemon"]
USER spotify

###
# Release image for portaudio-dbus
###
FROM debian:bookworm-20250407-slim AS portaudio-dbus-release
RUN apt-get update && \
    apt-get install -yqq --no-install-recommends ca-certificates libasound2 libdbus-1-3 libssl3 && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r spotify && \
    useradd --no-log-init -r -g spotify -G audio spotify
COPY --from=portaudio-dbus-build /usr/src/spotifyd/target/release/spotifyd /usr/bin/
CMD ["/usr/bin/spotifyd", "--no-daemon"]
USER spotify