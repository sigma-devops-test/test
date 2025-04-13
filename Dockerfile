ARG TERRAFORM_VERSION=1.11
#ARG KUBECTL_VERSION=1.32
ARG TERRAGRUNT_VERSION=1.11.3
ARG HELM_VERSION=3
ARG NVIM_VERSION=stable
ARG AZURE_CLI_VERSION=2.58.0

# Define stages for each tool
FROM hashicorp/terraform:${TERRAFORM_VERSION} AS terraform
#FROM bitnami/kubectl:${KUBECTL_VERSION} AS kubectl
FROM alpine/terragrunt:${TERRAGRUNT_VERSION} AS terragrunt
FROM alpine/helm:${HELM_VERSION} AS helm
FROM chn2guevara/nvim:${NVIM_VERSION} AS nvim
FROM mcr.microsoft.com/azure-cli:${AZURE_CLI_VERSION} AS azure-cli

FROM alpine:3.18
ENV RUNNING_IN_DOCKER=true

# Install dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    git \
    python3 \
    && ln -sf /usr/bin/python3 /usr/local/bin/python

# Install tools
COPY --from=terraform /bin/terraform /usr/local/bin/
#COPY --from=kubectl /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=helm /usr/bin/helm /usr/local/bin/
COPY --from=nvim /usr/local/bin/nvim /usr/local/bin/
COPY --from=azure-cli /usr/local/bin/az /usr/local/bin/
COPY --from=azure-cli /usr/local/lib/python3.11 /usr/local/lib/python3.11

# Set Python path for Azure CLI
ENV PYTHONPATH="/usr/local/lib/python3.11/site-packages"

# Ensure binaries are executable
RUN chmod +x /usr/local/bin/*

# https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-install-cli
RUN az aks install-cli

RUN apk add --no-cache \
    py3-pip \
    perl \
    bash \
    jq \
    yq \
    unzip \
    tar \
    openssh-client \
    fzf \
    bat \
    busybox-extras \
    iproute2 \
    xclip

# Set up unprivileged user
ARG USER=sigma
ENV HOME=/home/${USER}
RUN adduser -D -s /bin/bash -h ${HOME} ${USER} \
    && mkdir -p ${HOME}/.local/bin \
    && chown -R ${USER}:${USER} ${HOME}
ENV PATH="${PATH}:${HOME}/.local/bin"
WORKDIR ${HOME}

USER ${USER}

CMD ["/bin/bash"]
