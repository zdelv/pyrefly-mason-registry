FROM debian:bookworm

RUN apt update && apt install -y git luarocks curl python3 python3-venv

RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
        rm -rf /opt/nvim && \
        tar -C /opt -xzf nvim-linux-x86_64.tar.gz

RUN echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> /root/.bashrc
