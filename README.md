# Spotify Daemon in Docker
| Alsa | Alsa dbus | Pulseaudio | Pulseaudio dbus |
| --------- | --------------- | ----------- | ------- |
| ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-alsa) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-alsa) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-alsa-dbus) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-alsa-dbus) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-pulseaudio) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-pulseaudio) | ![Alsa Docker Pulls](https://img.shields.io/docker/pulls/hvalev/spotifyd-pulseaudio-dbus) ![Alsa Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/hvalev/spotifyd-pulseaudio-dbus) |
----------------------------------
[![build](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml)
![spotifyd%20version](https://img.shields.io/badge/spotifyd%20version-0.3.2-green)

Spotifyd within a docker container for ARM (armv7/arm64) and AMD (x32/x64) architectures in configuration variants alsa/pulseaudio for audio-backend and with/without D-Bus API for controlling spotifyd through generic media players.

## Insights
According to my subjective experience and available hardware, dbus in the alsa variant is better as it uses a software controller which appears to increase volume linearly. On the other hand the volume control with pure alsa renders anything below 60% practically unhearable and anything above 80% too loud. I haven't tested the pulseaudio version yet. Let me know if you have some feedback.

## How to run the alsa variant
```docker run -d --net host --group-add $(getent group audio | cut -d: -f3) --device /dev/snd:/dev/snd -v /usr/share/alsa:/usr/share/alsa -v $PWD/contrib/spotifyd.conf:/etc/spotifyd.conf hvalev/spotifyd-XXX``` where you need to replace ```XXX``` with the appropriate image in ```https://hub.docker.com/u/hvalev```.
or with docker-compose:
```
version: '3'
services:
  spotifyd:
    image: hvalev/spotifyd-XXX
    network_mode: host
    devices:
      - /dev/snd:/dev/snd
    volumes:
      - /usr/share/alsa:/usr/share/alsa
      - /etc/spotifyd/spotifyd.conf:/etc/spotifyd.conf
      - /etc/asound.conf:/etc/asound.conf
    group_add:
      - ${AUDIO_GRP}
```

If you're running this on a raspberry-pi, you can replace ${AUDIO_GRP} with 29 as that is the id of the audiogroup user. If not, simply type ```id``` in the terminal and enter whatever number shows next to (audio).

## How to run the pulseaudio variant
TBD

## How to build it
Grab the dockerfile with the configuration you wish to build and remove ```--platform=$BUILDPLATFORM``` from the first image.

## Information
At the moment the rust-fix intermediary build image exists as a workaround to this [bug](https://github.com/docker/buildx/issues/395).

## Limitations
Spotifyd requires a Spotify Premium account.

## Acknowledgements
Naturally, all credit goes to [spotifyd](https://github.com/Spotifyd/spotifyd). The instructions, dockerfile and explanation at [GnaphronG/docker-spotifyd](https://github.com/GnaphronG/docker-spotifyd) consititute a major portion of the contents in this repository.
