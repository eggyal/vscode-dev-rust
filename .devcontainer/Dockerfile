FROM mcr.microsoft.com/vscode/devcontainers/rust:1-bullseye@sha256:77b7c17b1a5a524937fd917ad16f98a952bfbcb27c20fc11ec054c73a0d3e38f AS base
ARG USER_UID=1000
ARG USER_GID="$USER_UID"
RUN groupmod --gid "$USER_GID" vscode \
    && usermod --uid "$USER_UID" --gid "$USER_GID" vscode \
    && chown -R "$USER_UID":"$USER_GID" /home/vscode \
    && apt-get update

FROM base as dev
COPY build-context/packages /tmp/
RUN xargs -a /tmp/packages apt-get -y install --no-install-recommends \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm /tmp/packages
USER vscode
COPY build-context/Cargo.toml /tmp/
RUN awk -F' = ' '/ = /{print $2 " " $1}' /tmp/Cargo.toml | xargs -n2 -P$(nproc) cargo install --locked --version \
    && sudo rm -rf /tmp/Cargo.toml "$CARGO_HOME/registry"
