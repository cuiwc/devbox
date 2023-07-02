# Devbox
#
# Version       1.0.0

FROM ubuntu

ARG MIRROR=mirrors.tuna.tsinghua.edu.cn
ARG USERNAME=wcui
ARG ZSH_THEME=cypher

#
# Configure APT mirror and install essential packages.
#
RUN sed -ie "s/archive.ubuntu.com/$MIRROR/g" /etc/apt/sources.list; \
    sed -ie "s/security.ubuntu.com/$MIRROR/g" /etc/apt/sources.list; \
    apt-get update; \
    apt-get -y install sudo vim build-essential bash-completion zsh git curl wget locales tmux software-properties-common python3-dev python3-pip python3-venv unzip ; \
    apt-get clean; \
    mkdir -p /etc/sudoers.d; \
    useradd -m -s /usr/bin/zsh $USERNAME; \
    echo "$USERNAME ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME; \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; locale-gen

#
# Change to default user.
#
WORKDIR /home/$USERNAME
USER $USERNAME

#
# Post-install configurations, in the user context.
#
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    sed -ie "s/robbyrussell/$ZSH_THEME/g" /home/$USERNAME/.zshrc

RUN sudo add-apt-repository ppa:neovim-ppa/unstable; \
    sudo apt-get update ; \
    sudo apt-get -y install neovim

RUN git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
COPY astronvim-user /home/$USERNAME/.config/nvim/lua/user
COPY env /home/$USERNAME/.env
RUN sudo chown wcui: -R ~/.env; \
    sudo chown wcui: -R ~/.config; \
    ln -s ~/.env/tmux.conf ~/.tmux.conf; ln -s ~/.env/tmux ~/.tmux ; \
    nvim --headless "+Lazy! sync" +qa ; \
    nvim --headless +"sleep 5" +"MasonInstall clangd" +"MasonInstall jedi-language-server" +"sleep 5" +qa

#
# Environments
#
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/zsh"]

