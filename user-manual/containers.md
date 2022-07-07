# Containers and Their Runners

A simple description (although not perfectly accurate) of a container is a lightened virtual machine.
A container is run using an engine (docker, singularity, and podman are popular options) which allows
for the container to interact with the host operating system. Unlike a virtual machine, the container
is only supposed to have the necessary libraries and binaries to do the task for which it is designed.
This allows a container to be opened and closed quickly especially compared to a full virtual machine.

A container is run by reading a container image. An image is built also using a container engine and
that is where the libraries and binaries are compiled and installed for the task.

Docker has a [good page](https://www.docker.com/resources/what-container/) about what containers are.

On this cluster, we have singularity installed and standard users are able to run singularity images
and build singularity images from pre-built layers available online. (singularity images _cannot_ be
built directly from a definition file since this requires security-weakening permissions.) A common
workflow is to build a container image using docker on a personal laptop or on GitHub and push that 
image to DockerHub where it can be downloaded onto the cluster for parallel running.

While CVMFS can cover most of the dependencies required for the software we use, containers can 
cover the rest. Building your first container image and using a container for running can be very
difficult; however, it is a very good way of standardizing how a specific application can be run.

A full description on how to write your first container image and use a container is out of the scope
of this manual; however, below I have included links to example repositories and documentation that
can help you get started.

### Helpful Resources
- [singularity documentation](https://docs.sylabs.io/guides/3.8/user-guide/)
- [docker docs Get Started](https://docs.docker.com/get-started/)
- [dark-brem-lib-gen](https://github.com/tomeichlersmith/dark-brem-lib-gen) : containerized MadGraph4 
  that works with either singularity or docker
- [LDMX-Software/docker](https://github.com/LDMX-Software/docker) : containerized development environment
  for ldmx-sw
