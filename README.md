# Spotify Daemon in Docker
[![build](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml/badge.svg)](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml)
![spotifyd%20version](https://img.shields.io/badge/spotifyd%20version-0.3.0-green)

Repository building spotifyd for docker for ARM (armv7/arm64) and AMD (x32/x64) architectures. This workflow builds the mixture of feature configurations consisting of alsa/pulseaudio audio-backend and with/without D-Bus API for controlling spotifyd through generic media players.

## How to run it
```docker run -d --net host --group-add $(getent group audio | cut -d: -f3) --device /dev/snd:/dev/snd -v /usr/share/alsa:/usr/share/alsa -v $PWD/contrib/spotifyd.conf:/etc/spotifyd.conf hvalev/spotifyd-XXX``` where you need to replace ```XXX``` with the appropriate image in ```https://hub.docker.com/u/hvalev```.
or with docker-compose:
```
version: '3'
services:
	spotifyd:
		image: "hvalev/spotifyd-XXX"
		network_mode: "host"
		devices:
			- "/dev/snd:/dev/snd"
		volumes:
			- "/usr/share/alsa:/usr/share/alsa"
			- "/etc/spotifyd/spotifyd.conf:/etc/spotifyd.conf"
			- "/etc/asound.conf:/etc/asound.conf"
		group_add:
			- "${AUDIO_GRP}"
```
## How to build it
Grab the dockerfile you wish to build and remove ```--platform=$BUILDPLATFORM``` from the first image. At the moment rust-fix intermediary image exists to go around this [bug](https://github.com/docker/buildx/issues/395).

## Limitations
Spotifyd requires a Spotify Premium account.

## Acknowledgements
Naturally, all credit goes to [spotifyd](https://github.com/Spotifyd/spotifyd). The instructions, dockerfile and explanation at [GnaphronG/docker-spotifyd](https://github.com/GnaphronG/docker-spotifyd) consititute a major portion of what is contained in this repository.
