FROM imx6sx-lm-base

RUN pacman-key --init && pacman-key --populate
RUN pacman -Rns --noconfirm \
    linux-armv7 \
    mkinitcpio \
    mkinitcpio-busybox \
    linux-firmware \
    linux-firmware-whence
RUN sed -i '/CheckSpace/d' /etc/pacman.conf
RUN --mount=target=/var/cache/pacman/pkg,type=cache,rw=true pacman -Syu --noconfirm
RUN --mount=target=/var/cache/pacman/pkg,type=cache,rw=true pacman -S --noconfirm \
    base-devel \
    htop \
    tmux \
    vim \
    strace \
    git \
    gdb \
    python \
    wget \
    cmake \
    ninja


RUN sed -i 's/#\s*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
RUN passwd -d root
RUN userdel -r alarm
RUN sed -Ei 's/\s*#\s*PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
RUN sed -Ei 's/\s*#\s*PasswordAuthentication\s+(yes|no)/PasswordAuthentication no/' /etc/ssh/sshd_config
ADD files/ /
