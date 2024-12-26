# bitnami-mongodb-arm

Amazed by the fact that official `bitnami/mongodb` images are not available for arm64, this repository was created and
provides build files for custom `bitnami/mongodb` compatible images. These can be used for example with the official
[bitnami mongodb helm charts](https://github.com/bitnami/charts/tree/main/bitnami/mongodb). While the build process is
based on the official [bitnami/mongodb](https://github.com/bitnami/containers/tree/main/bitnami/mongodb/) and
[mongo](https://github.com/docker-library/mongo/) Dockerfiles and binaries, it is a private project and not supported
neither by bitnami nor by mongodb. The resulting images are meant to be only used for local development on arm64-based
hardware and should not be used on production.

This repository contains build files for following mongodb versions:
- [6.0.13](6.0)

## How-to build and use the images

To build a docker image, first  go to the image directory you want to use in the terminal, f.e:

```shell
cd 6.0/debian-12
```

Then run following docker build command to build and tag an image. The following example will produce an image with the
`bitnami-mongodb:6.0.13-local` tag:

```shell
docker build -t bitnami-mongodb:6.0.13-local .
```

You can now use the image `bitnami-mongodb:6.0.13-local` locally.

### Usage via docker compose

Example usage with [mongodb 6.0 docker-compose.yaml](6.0/debian-12/docker-compose.yml):

```shell
docker compose up
```

### Usage with official helm charts

Then running mongodb via helm charts, in most setups your k8s environment will not have access to the local image
registry, you will need to upload the image to your registry first. For [minikube](https://minikube.sigs.k8s.io/docs/)
you can use:

```shell
minikube image load bitnami-mongodb:6.0.13-local
```

This will make the image available as `docker.io/library/bitnami-mongodb:6.0.13-local`. You can now start the mongodb
container with the provided example [values.yaml](6.0/debian-12/values.yaml):

```shell
 helm install mongo -f values.yaml oci://registry-1.docker.io/bitnamicharts/mongodb
```