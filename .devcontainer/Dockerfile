FROM mcr.microsoft.com/vscode/devcontainers/rust:1-bullseye@sha256:7a4c4c8b4516b6360edcfe0e8eaefad01ac94542634504658e29b35f0b7ea600 AS base
ARG USER_UID=1000
ARG USER_GID="$USER_UID"
RUN groupmod --gid "$USER_GID" vscode \
    && usermod --uid "$USER_UID" --gid "$USER_GID" vscode \
    && chown -R "$USER_UID":"$USER_GID" /home/vscode \
    && apt-get update

FROM base AS mold
COPY build-context/mold.build-packages build-context/mold.url /tmp/
RUN xargs -a /tmp/mold.build-packages apt-get -y install --no-install-recommends \
    && rm /tmp/mold.build-packages
USER vscode
RUN mkdir ~/mold \
    && cd ~/mold \
    && xargs -a /tmp/mold.url curl -fsSL --proto '=https' --tlsv1.2 | tar xz --strip-components=1 \
    && make -j$(nproc) \
    && sudo make install

FROM base AS dev
COPY build-context/packages /tmp/
RUN xargs -a /tmp/packages apt-get -y install --no-install-recommends \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm /tmp/packages
USER vscode
COPY build-context/Cargo.toml /tmp/
RUN awk -F' = ' '/ = /{print $2 " " $1}' /tmp/Cargo.toml | xargs -n2 -P$(nproc) cargo install --locked --version \
    && sudo rm -rf /tmp/Cargo.toml "$CARGO_HOME/registry" \
    # && rustup toolchain list | awk '{print $1}' | xargs rustup uninstall \
    && sudo install -m 755 -d /usr/{bin,lib}/mold
COPY --from=mold /usr/bin/mold /usr/bin/mold/ld
COPY --from=mold /usr/lib/mold /usr/lib/mold/
