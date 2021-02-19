# Spotify Daemon in Docker
[![build](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/hvalev/spotifyd-docker/actions/workflows/build.yml)
![spotifyd%20version](https://img.shields.io/badge/spotifyd%20version-0.2.25-1-green)

Repository building spotifyd for docker for ARM (armv7/arm64) and AMD (x32/x64) architectures. This workflow builds the mixture of feature configurations alsa/pulseaudio backend and with/without dbus to allow for quickly swapping containers and figuring which works best. 


Spotifyd requires a Spotify Premium account.


## rust fix

```--platform=$BUILDPLATFORM```
