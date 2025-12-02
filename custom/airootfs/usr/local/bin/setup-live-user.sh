#!/bin/bash

# Visual helpers
BOLD='\033[1m'
RESET='\033[0m'
step() { echo -e "${BOLD}==> $1${RESET}" && eval "$2"; }

build() {
  step "Creating build workspace..." "mkdir -p /tmp/isobuild"
  
  # 1. Install archiso tools
  step "Installing archiso..." "pacman -Syu --noconfirm archiso"
  
  # 2. Copy the default releng profile
  step "Copying releng profile..." "cp -r /usr/share/archiso/configs/releng/* /tmp/isobuild"
  
  # 3. Add Custom Packages
  step "Adding custom packages..." "cat custom-packages.txt >> /tmp/isobuild/packages.x86_64"
  
  # 4. Copy Custom Files
  step "Copying custom configurations..." "cp -r custom/airootfs/* /tmp/isobuild/airootfs/"
  
  # 5. FIXED: Create User PERMANENTLY via Chroot
  # This runs inside the ISO filesystem before it's packed.
  # We use arch-chroot to ensure the user is added to the actual /etc/passwd of the ISO.
  step "Creating 'arch' user in build filesystem..." "
    arch-chroot /tmp/isobuild/airootfs /bin/bash -c '
      useradd -m -G wheel,video,audio,input,storage -s /bin/zsh arch &&
      echo \"arch:arch\" | chpasswd
    '
  "

  # 6. Enable Services
  step "Enabling Systemd Services..." "
    mkdir -p /tmp/isobuild/airootfs/etc/systemd/system/multi-user.target.wants
    
    # NetworkManager
    ln -sf /usr/lib/systemd/system/NetworkManager.service \
       /tmp/isobuild/airootfs/etc/systemd/system/multi-user.target.wants/
       
    # Bluetooth (if you added bluez)
    ln -sf /usr/lib/systemd/system/bluetooth.service \
       /tmp/isobuild/airootfs/etc/systemd/system/multi-user.target.wants/
  "

  # 7. Permissions Fixes
  step "Setting sudo permissions..." "
    chmod 440 /tmp/isobuild/airootfs/etc/sudoers.d/live-user
    chown -R root:root /tmp/isobuild/airootfs/etc/sudoers.d
  "

  # 8. Build ISO
  step "Building ISO..." "mkarchiso -v -w work/ -o ./ /tmp/isobuild"
  
  # 9. Checksums
  ISO_NAME=$(ls | grep "archlinux-.*-x86_64.iso" | head -n1)
  step "Generating checksums..." "
    b2sum $ISO_NAME > CHECKSUMS.txt
    sha256sum $ISO_NAME >> CHECKSUMS.txt
  "
}

if [ -z ${DATE+x} ]; then
  echo "DATE variable not set! (Run via Github Actions)" && exit 1
else
  build
fi
