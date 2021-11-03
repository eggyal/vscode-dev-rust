FROM mcr.microsoft.com/vscode/devcontainers/rust:1-bullseye@sha256:15bb5f3481935669985c917b8d613966c601d20601a4bdd219d770739a7a17a1 AS base

FROM base AS mold
COPY mold.build-packages mold.url /tmp/
RUN apt-get update \
    && xargs -a /tmp/mold.build-packages apt-get -y install --no-install-recommends \
    && rm /tmp/mold.build-packages
USER vscode
RUN mkdir ~/mold \
    && cd ~/mold \
    && xargs -a /tmp/mold.url curl -fsSL --proto '=https' --tlsv1.2 | tar xz --strip-components=1 \
    && make -j$(nproc) \
    && sudo make install

FROM base AS dev
RUN apt-get autoremove -y
USER vscode
COPY Cargo.toml /tmp/
RUN awk -F' = ' '/ = /{print $2 " " $1}' /tmp/Cargo.toml | xargs -n2 -P$(nproc) cargo install --locked --version \
    && sudo rm -rf /tmp/Cargo.toml "$CARGO_HOME/registry" \
    # && rustup toolchain list | awk '{print $1}' | xargs rustup uninstall \
    && sudo install -m 755 -d /usr/{bin,lib}/mold
COPY --from=mold /usr/bin/mold /usr/bin/mold/ld
COPY --from=mold /usr/lib/mold /usr/lib/mold/