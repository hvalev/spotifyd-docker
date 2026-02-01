# Spotify Daemon in Docker
| Alsa | Alsa dbus | Pulseaudio | Pulseaudio dbus |
| --------- | --------------- | ----------- | ------- |
| ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-alsa) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-alsa) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-alsa-dbus) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-alsa-dbus) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-pulseaudio) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-pulseaudio) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-pulseaudio-dbus) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-pulseaudio-dbus) |
----------------------------------
[![build](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml)
![spotifyd%20version](https://img.shields.io/badge/spotifyd%20version-0.4.0-green)

Spotifyd within a docker container for ARM and x86 architectures. Comes in flavors `alsa`/`pulseaudio` for audio-backend and with/without dbus support. There is a sample `spotifyd.conf` config catering to the `alsa-dbus` variant in the repository which you can use to bootstrap your container. With zeroconf you should not need to provide a config file. For posterity a `spotifyd.conf` is provided in the repo.

NOTE: only the alsa-dbus variant has been tested, if you have a working `pulseaudio` setup, feel free to contribute a working config or a working docker-compose definition.

## How to run the alsa-dbus variant
```yaml
services:
  spotifyd:
    container_name: spotify
    restart: always
    image: hvalev/spotifyd-alsa-dbus
    network_mode: host
    # Keep in mind to keep the ports for zeroconf and mdns open on the host
    devices:
      - /dev/snd:/dev/snd
```

## How to run the pulseaudio variant
```yaml
services:
  spotify:
    container_name: spotify
    restart: always
    image: hvalev/spotifyd-pulseaudio
    user: ${PUID}:${PGID}
    network_mode: host
    devices:
      - /dev/snd:/dev/snd
    environment: 
      - PULSE_SERVER=unix:/tmp/pulseaudio.socket
      - PULSE_COOKIE=/tmp/pulseaudio.cookie
    volumes:
      - /run/user/1000/pulse/native:/tmp/pulseaudio.socket
```

## Insights
On a raspberry-pi with the `alsa-dbus` variant and using `softvol` for `volume_controller` only the volume range 60-100 is usable. Everything below that is very quiet.

With version `0.4.0`, the authentication has changed to use zeroconf for authentication and mDNS to announce the service to the network. mDNS requires a device to announce it's service and only devices 1 hop away on the local network can actually discover it. Thus, running spotifyd in a container prevents mDNS from working. The quick and dirty fix is to run `network_mode: host` and use the host's network. Beware that in that case spotify will use the ports `33797` for zeroconf (if you use the config in the repo) and `5353` for mDNS. This won't be implicit or obvious in the `docker-compose.yml` defition. There is an option to use something like avahi-daemon to reflect mdns traffic, but it requires a lot more configuration.

## How to build it
Grab the dockerfile with the configuration you wish to build and remove ```--platform=$BUILDPLATFORM``` from the first image. Since a single Dockerfile is used for all images, you also need to add `--target alsa-dbus-release` or another flavor to build along with your build command.

## Information
At the moment the rust-fix intermediary build image exists as a workaround to this [bug](https://github.com/docker/buildx/issues/395).

## Limitations
Spotifyd requires a Spotify Premium account.

## Acknowledgements
Naturally, all credit goes to [spotifyd](https://github.com/Spotifyd/spotifyd). The instructions, dockerfile and explanation at [GnaphronG/docker-spotifyd](https://github.com/GnaphronG/docker-spotifyd) have been very helpful in getting this up and running.
