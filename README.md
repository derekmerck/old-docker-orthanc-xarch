Orthanc xArch Docker Image
==========================

Derek Merck  
<derek_merck@brown.edu>  
Rhode Island Hospital and Brown University  
Providence, RI  

Build [Orthanc](https://www.orthanc-server.com) DICOM-node Docker images for multiple architectures.


Supported Architectures
-----------------------

This image is based on the `resin/$ARCH-debian:stretch` image.  Resin.io's base images include a Qemu cross-compiler to facilitate building images for low-power single-board computers on more powerful Intel-architecture desktops and servers.

### `amd64`

Desktop computers/vms, some UP boards, and the Intel NUC are `amd64` devices.  The appropriate image can be built and pushed from Travis CI.

### `arm32v7`
 
Most low-power single board computers such as the Raspberry Pi and Beagleboard are `arm32v7` devices.  Cross-compiling the appropriate image takes too long on Travis CI, so it currently has to be tediously cross-compiled and pushed locally.

### `arm64v8`
 
The NVIDIA Jetson TX2 uses a Tegra `arm64v8` cpu.  The appropriate image can be built natively and pushed from Packet.io, using a short tenancy on a bare-metal Cavium ThunderX ARMv8 server.

Although Resin uses Packet ARM servers to compile arm32 images, the ThunderX does not implement the arm32 instruction set, so it cannot be used to compile natively for the Raspberry Pi.

- https://resin.io/blog/docker-builds-on-arm-servers-youre-not-crazy-your-builds-really-are-5x-faster/
- https://gitlab.com/gitlab-org/omnibus-gitlab/issues/2544


Building
--------------

`docker-compose.yml` contains build descriptions for all relevant architectures.

### `amd64` builds

```bash
$ docker-compose build orthanc-amd64
```

### `amd64` builds

```bash
$ docker-compose build orthanc-arm32v7
```

### `arm64v8` builds on Packet

```bash
$ apt update && apt upgrade
$ curl -fsSL get.docker.com -o get-docker.sh
$ sh get-docker.sh 
$ docker run hello-world
$ apt install git python-pip
$ pip install docker-compose
$ git clone http://github.com/derekmerck/orthanc-xarch
$ cd orthanc-xarch
$ docker-compose build orthanc-arm64v8
```

Manifest-it
----------------

After building new images, call `manifest-it.py` to push updated images and build the Docker
multiarchitecture service mappings.

```bash
$ python3 manifest-it rcd-manifests.yml
```


License
-------

MIT
