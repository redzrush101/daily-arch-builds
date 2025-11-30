#!/bin/bash
# Create user 'arch' with password 'arch'
# zsh is in the default package list, so we can use it safely.
if ! id "arch" &>/dev/null; then
    useradd -m -G wheel,video,audio,input,storage -s /bin/zsh arch
    echo "arch:arch" | chpasswd
fi
