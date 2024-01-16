FROM codercom/code-server

USER root

RUN dpkg --add-architecture i386 && apt-get update && apt-get upgrade -y

RUN apt-get update && apt-get upgrade &&        \
    apt-get install -y --no-install-recommends   \
    systemd                              \
    systemd-sysv                         \
    libsystemd0                          \
    ca-certificates                      \
    dbus                                 \
    iptables                             \
    iproute2                             \
    kmod                                 \
    locales                              \
    sudo                                 \
    udev &&                              \
    \
    # Prevents journald from reading kernel messages from /dev/kmsg
    echo "ReadKMsg=no" >> /etc/systemd/journald.conf

RUN systemctl mask systemd-udevd.service \
    systemd-udevd-kernel.socket \
    systemd-udevd-control.socket \
    systemd-modules-load.service \
    systemd-udev-trigger.service \
    systemd-journald-audit.socket \
    sys-kernel-config.mount \
    sys-kernel-debug.mount \
    sys-kernel-tracing.mount

RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
RUN apt-get install -y unzip file wget vim python3 python3-pip python3-dev python3-venv clangd tshark \
    gcc-multilib make build-essential pkg-config patchelf elfutils gdb gdb-multiarch \
    gdb-multiarch libc6:i386 libncurses5:i386 libstdc++6:i386 libssl-dev libffi-dev \
    libpcre3-dev libdb-dev libxt-dev libxaw7-dev liblzma-dev netcat-openbsd python3-pwntools zip

RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

RUN usermod -aG docker coder

USER coder

RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-python.black-formatter
RUN code-server --install-extension llvm-vs-code-extensions.vscode-clangd
RUN code-server --install-extension ms-vscode.hexeditor
RUN code-server --install-extension rangav.vscode-thunder-client
RUN code-server --install-extension mechatroner.rainbow-csv
RUN code-server --install-extension sndst00m.vscode-native-svg-preview

RUN pip install --break-system-packages pyshark

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/home/coder/.cargo/bin:${PATH}"

RUN cargo install fnm
RUN fnm install 20
RUN echo 'eval "$(fnm env --use-on-cd)"' >> ~/.bashrc

RUN curl -fsSL https://bun.sh/install | bash

RUN wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
RUN echo source ~/.gdbinit-gef.py >> ~/.gdbinit

RUN sudo ln -s /usr/lib/code-server/lib/vscode/bin/remote-cli/code-server /usr/bin/code

COPY vscode-settings.json /home/coder/.local/share/code-server/User/settings.json
RUN sudo chown coder:coder /home/coder/.local/share/code-server/User/settings.json

RUN mkdir workspace

COPY media /usr/lib/code-server/src/browser/media

USER root

COPY login.html /usr/lib/code-server/src/browser/pages/login.html
RUN sed -i -e 's/<\/html>/<script>const params = new URLSearchParams(window.location.search);params.delete("password");window.history.replaceState(null, "", window.location.pathname + "?" + decodeURIComponent(params));<\/script><\/html>/g' /usr/lib/code-server/lib/vscode/out/vs/code/browser/workbench/workbench.html

COPY code-server.service /etc/systemd/system/code-server.service
RUN systemctl enable code-server.service

# Make use of stopsignal (instead of sigterm) to stop systemd containers.
STOPSIGNAL SIGRTMIN+3

# Set systemd as entrypoint.
ENTRYPOINT [ "/sbin/init", "--log-level=err" ]
