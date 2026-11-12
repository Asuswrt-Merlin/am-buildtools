# am-buildtools
This repository contains various scripts, docker config files and such used for maintaining/building the Asuswrt-Merlin firmware.

## Docker build environment

The `docker/` folder provides Ubuntu 20.04 and 22.04 build containers, plus the
`mbuild` and `mbuild22` commands to run builds inside them.

### Requirements

- A Linux host (the host's `/etc/passwd` and `/etc/group` are used inside the container)
- Docker Engine with the Compose v2 plugin (`docker compose`, not `docker-compose`)
- Permission to run Docker as your regular user (typically by being a member of the `docker` group)
- About 2.5 GB of disk space per image (you may only need one, see [Usage](#usage))

### Install

1. Clone [am-toolchains](https://github.com/RMerl/am-toolchains) somewhere on your system.

2. Pick a build root directory and clone the
   [Asuswrt-Merlin source](https://github.com/RMerl/asuswrt-merlin.ng) inside it.
   Only this directory is visible inside the container, so every source tree you
   want to build must be located under it. It can hold multiple copies, for
   example one per model:

   ```
   ~/build/
   ├── amng.ax88/
   └── amng.be92/
   ```

3. Configure your paths:

   ```sh
   cd docker
   cp .env.example .env
   ```

   Edit `.env` and set `AM_BUILD_ROOT` to your build root directory,
   and `AM_TOOLCHAINS` to your am-toolchains checkout.

4. Optional: download the images in advance. Otherwise, the image you need is
   automatically downloaded the first time you use `mbuild` or `mbuild22`.

   ```sh
   docker compose pull
   ```

   To build the images locally instead (for example after modifying the
   `Dockerfile`), use `docker compose build`.

5. Install the `mbuild` and `mbuild22` commands by symlinking them into a directory
   on your `PATH` (from within the `docker/` folder):

   ```sh
   ln -s "$PWD/mbuild" "$PWD/mbuild22" ~/.local/bin/
   ```

   On Ubuntu, `~/.local/bin` is only added to your `PATH` at login if it already
   exists. If you just created it, log out and back in.

### Usage

`mbuild` runs a command in the Ubuntu 20.04 container, and `mbuild22` in the
Ubuntu 22.04 container. Run them from anywhere inside your build root: the current
directory is mapped to the same location inside the container (under
`/workspace/build`). Without a command, an interactive shell is started.

Two environments are needed, as the older SDKs fail to build under Ubuntu 22.04.
Use the container matching the model you are building:

| Model | Command |
|---|---|
| RT-BE92U | `mbuild22` |
| All other models | `mbuild` |

```sh
cd ~/build/amng.ax88/release/src-rt-5.02axhnd
mbuild make rt-ax88u

cd ~/build/amng.be92/release/src-rt-5.04behnd.4916
mbuild22 make rt-be92u
```

Builds run as your own user, so all generated files are owned by you.

### Advanced

#### Additional mounts

To make other host directories available inside the container (for instance a
network share to store built images), create a `docker/docker-compose.override.yml`
file. It is automatically used by `mbuild`, and ignored by git:

```yaml
x-local: &local
  volumes:
    - /media/nas:/media/nas

services:
  build-2004: *local
  build-2204: *local
```

#### Passing variables to the build

`MBUILD_ENV` holds a list of host environment variable names to pass into the
container. This is mostly useful in build scripts:

```sh
export BUILDREV=1 MERLINUPDATE=y
export MBUILD_ENV="BUILDREV MERLINUPDATE"
mbuild make rt-ax88u
```

#### Updating

To update to the latest published images, then remove the previous, now unused
images:

```sh
docker compose pull
docker image prune
```

If you build the images locally, rebuild them with `docker compose build` after
pulling changes to this repository.

#### Time zone

Containers use UTC by default. Set `TZ` in `.env` to change it, for example
`TZ=America/Toronto`.
