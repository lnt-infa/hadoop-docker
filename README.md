# Apache Hadoop 2.7.5 Docker image

# Build the image

If you'd like to try directly from the Dockerfile you can build the image as:

```
docker build  -t lntinfa/hadoop-docker:2.7.5 .
```
# Pull the image

The image is also released as an official Docker image from Docker's automated build repository - you can always pull or refer the image when launching containers.

```
docker pull lntinfa/hadoop-docker:2.7.5
```

# Start a container

In order to use the Docker image you have just build or pulled use:

**Make sure that SELinux is disabled on the host. If you are using boot2docker you don't need to do anything.**

```
docker run -it lntinfa/hadoop-docker:2.7.5 /etc/bootstrap.sh -bash
```

