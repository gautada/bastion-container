ARG ALPINE_VERSION=3.15.4
# ╭――――――――――――――――---------------------------------------------------------――╮
# │                                                                           │
# │ STAGE 1: bastion-container                                                 │
# │                                                                           │
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM gautada/alpine:$ALPINE_VERSION

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/bastion-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="Bastion container is an OpenSSH implementation."

# ╭――――――――――――――――――――╮
# │ ENVIRONMENT        │
# ╰――――――――――――――――――――╯
ENV ENV="/etc/profile"
USER root
WORKDIR /
ARG OPENSSH_VERSION
ARG OPENSSH_PACKAGE="$OPENSSH_VERSION"-r1

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache openssh=$OPENSSH_PACKAGE

# ╭――――――――――――――――――――╮
# │ SUDO               │
# ╰――――――――――――――――――――╯
COPY wheel-bastion.sudoers /etc/sudoers.d/wheel-bastion.sudoers

# ╭――――――――――――――――――――╮
# │ HEALTHCHECK        │
# ╰――――――――――――――――――――╯
COPY hc-bastion.sh /etc/healthcheck.d/hc-bastion.sh

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY 01-ep-bastion.sh /etc/entrypoint.d/01-ep-bastion.sh

# ╭――――――――――――――――――――╮
# │ PORTS              │
# ╰――――――――――――――――――――╯
EXPOSE 22/tcp

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY bastion-setup /usr/bin/bastion-setup
COPY bastion.conf /etc/ssh/bastion.conf
RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config~ \
 && ash -c "/bin/cat /etc/ssh/sshd_config~ /etc/ssh/bastion.conf > /etc/ssh/sshd_config"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=bastion
VOLUME /opt/$USER
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/chown $USER:$USER -R /opt/$USER

USER $USER
WORKDIR /home/$USER
