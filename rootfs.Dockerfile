ARG FROM
FROM ${FROM}

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
    ninja \
    minicom

RUN cd /tmp \
    && git clone https://github.com/linux-can/can-utils.git \
    && cd can-utils \
    && git checkout 6b46063eee805e0e680833da02fc16f15b92bf1e \
    && cmake . \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/can-utils/

RUN sed -i 's/#\s*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen
RUN passwd -d root
RUN userdel -r alarm
RUN sed -Ei 's/\s*#\s*PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
RUN sed -Ei 's/\s*#\s*PasswordAuthentication\s+(yes|no)/PasswordAuthentication no/' /etc/ssh/sshd_config

# install sllin.ko
ARG BOARD
RUN --mount=type=bind,source=out/${BOARD}/linux/include/config/,target=/mnt/config \
    --mount=type=bind,source=linux-lin,target=/mnt/linux-lin \
    KERNEL_RELEASE=$(< /mnt/config/kernel.release) \
    && install -D /mnt/linux-lin/sllin/sllin.ko /usr/lib/modules/$(</mnt/config/kernel.release)/extra/sllin.ko \
    && depmod -a ${KERNEL_RELEASE}

ADD files/ /
