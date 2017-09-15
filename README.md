LineageOS Docker Build Environment
====================================================

[![Docker Stars](https://img.shields.io/docker/stars/benlue/los-build.svg)](https://hub.docker.com/r/benlue/los-build/)
[![Docker Pulls](https://img.shields.io/docker/pulls/benlue/los-build.svg)](https://hub.docker.com/r/benlue/los-build/)
[![ImageLayers](https://images.microbadger.com/badges/image/benlue/los-build.svg)](https://microbadger.com/#/images/benlue/los-build)

Minimal build environment for LOS with handy automation wrapper scripts.

Developers can use the Docker image to build directly while running the
distribution of choice, without having to worry about breaking the delicate
LOS build due to package updates as is sometimes common on bleeding edge
rolling distributions like Arch Linux.

Production build servers and integration test servers should also use the same
Docker image and environment. This eliminates most surprise breakages by
by empowering developers and production builds to use the exact same
environment.  The devs will catch the issues with build environment first.

This works well on Linux.  Running this via `boot2docker` (and friends) will
result in a very painful performacne hit due to VirtualBox's `vboxsf` shared
folder service which works terrible for **very** large file shares like LOS.
It might work, but consider yourself warned.  If you're aware of another way to
get around this, send a pull request!


Quickstart
----------

For the terribly impatient.

1. Make a directory to work and go there.
2. Export the current directory as the persistent file store for the `los`
   wrapper.
3. Run a self contained build script, which does:
    1. Attempts to fetch the `los` wrapper if not found locally.
    2. Runs the `los` wrapper with an extra argument for the docker binary and
       hints to the same script that when run later it's running in the docker
       container.
    3. The los wrapper then does it's magic which consists of fetching the
       docker image if not found and forms all the necessary docker run
       arguments seamlessly.
    4. The docker container runs the other half the build script which
       initializes the repo, fetches all source code, and builds.
    5. In parallel you are expected to be drinking because I save you some time.

            mkdir los ; cd los
            export LOS_VOL=$PWD
            curl -O https://gitlab.s3root.ovh/LineageOS/docker_los_build/raw/master/tests/build_los.sh
            bash ./build_los.sh

    This takes about 2 hours to download and build on i5-2500k with 100Mb/s network connection.

How it Works
------------

The Dockerfile contains the minimal packages necessary to build Android based
on the main Ubuntu base image.

The `los` wrapper is a simple wrapper to simplify invocation of the Docker
image.  The wrapper ensures that a volume mount is accessible and has valid
permissions for the `los` user in the Docker image (this unfortunately
requires sudo).  It also forwards an ssh-agent in to the Docker container
so that private git repositories can be accessed if needed.

The intention is to use `los` to prefix all commands one would run in the
Docker container.  For example to run `repo sync` in the Docker container:

    los repo sync -j2

The `los` wrapper doesn't work well with setting up environments, but with
some bash magic, this can be side stepped with short little scripts.  See
`tests/build-los.sh` for an example of a complete fetch and build of LineageOS.

[Docker Compose][]
------

A [Docker Compose][] file is provided in the root of this repository, you can tweak it as need be:

```yaml
version: "2"

services:
  los:
    image: benlue/los-build:latest
    volumes:
      - /tmp/ccache:/ccache
      - ~/los:/los
```
Example run: `docker-compose run --rm los repo sync -j4` -- your android build directory will be in `~/los`.

Issues
------

There are some known issues with using Docker Toolbox on macOS and current
virtualization technologies resulting in unusual user ID assignments and very
poor performing virtualization file sharing implementations with things like
VirtualBox.  It's recommended to run this image completely in a virtual machine
with enough space to fit the entire build (80GB+) as opposed to mapping the
build to the local macOS file system via VirtualBox or similar.

Tested
------

* Android Kitkat `android-4.4.4_r2.0.1`
* Android Lollipop `android-5.0.2_r1`
* Android Marshmallow `android-6.0.1_r80`
* Android Nougat `android-7.0.0_r14`

[Docker Compose]: https://docs.docker.com/compose
