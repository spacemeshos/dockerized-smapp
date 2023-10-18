# syntax=docker/dockerfile:1-labs
FROM ubuntu:22.04 AS builder
ARG SMAPP_VERSION=master
ARG NODE_PACKAGE=nodejs
ARG NODE_MAJOR_VERSION

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libnss3 libgtk-3-0 libxss1 libasound2 ocl-icd-libopencl1 unzip curl binutils build-essential ca-certificates gnupg

RUN mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && NODE_MAJOR="${NODE_MAJOR_VERSION}" && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y "${NODE_PACKAGE}" && npm install --global yarn


RUN adduser --disabled-password --gecos '' spacemesh 
ADD --keep-git-dir=true https://github.com/spacemeshos/smapp.git#${SMAPP_VERSION} /home/spacemesh 
COPY ./no-sandbox-smapp /home/spacemesh
RUN chown -R spacemesh.spacemesh /home/spacemesh 
USER spacemesh
WORKDIR /home/spacemesh

RUN [ "/bin/bash", "-c",  "curl -L -o /tmp/Linux.zip \"https://storage.googleapis.com/go-spacemesh-release-builds/$(<node/use-version)/Linux.zip\" && unzip /tmp/Linux.zip && mkdir -p node/linux && mv Linux/* node/linux && rmdir Linux" ]

RUN chmod +x node/linux/profiler # Installer doesn't do this for some reason

ENV SENTRY_AUTH_TOKEN=
ENV SENTRY_DSN=

RUN yarn && yarn build && yarn package-linux


FROM ubuntu:22.04 

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl gnupg ca-certificates

RUN mkdir -p /usr/share/keyrings && curl -fsSL https://xpra.org/xpra.asc > /usr/share/keyrings/xpra.asc && curl -fsSL https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/jammy/xpra.sources > /etc/apt/sources.list.d/xpra.sources && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y xpra-server xpra-codecs xpra-codecs-extras xpra-codecs-nvidia

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN adduser --disabled-password --gecos '' spacemesh 
RUN chown -R spacemesh /home/spacemesh

COPY --from=builder /home/spacemesh/release/*_amd64.deb /tmp
RUN dpkg -i /tmp/*_amd64.deb ; apt install -y -f
COPY ./no-sandbox-smapp /usr/local/bin

USER spacemesh
ENTRYPOINT ["/usr/bin/xpra"]

EXPOSE 7513
EXPOSE 9999
