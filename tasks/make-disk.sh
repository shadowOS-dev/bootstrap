#!/bin/bash
set -e

# Example usage: ./make-image.sh shadowOS.iso ramfs.img system-root
IMAGE_NAME="$1"
INITRAMFS_PATH="$2"
SYSROOT="$3"
ROOT="$4"

# Validate arguments
if [[ -z "$IMAGE_NAME" || -z "$INITRAMFS_PATH" || -z "$SYSROOT" ]]; then
    echo "Usage: $0 <image_name> <initramfs_path> <sysroot>"
    exit 1
fi

# Generate the initramfs based on sysroot
rm -rf "$INITRAMFS_PATH"
tar -cvf "$INITRAMFS_PATH" -C "$SYSROOT" .

# Generate final image
TEMP=$(mktemp -d)
pushd "$TEMP"
mkdir -p boot
cp -vr "$SYSROOT/boot" .
cp -vr "$ROOT/extras/limine/limine.conf" boot/
cp -vr "$INITRAMFS_PATH" boot/ramfs.img

# Download and build Limine in TEMP if not present
if [[ ! -d "limine" ]]; then
    git clone https://github.com/limine-bootloader/limine.git --branch=v8.x-binary --depth=1
    make -C limine
fi

popd
xorriso -as mkisofs -R -r -J -b limine/limine-bios.sys \
        -no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
        -apm-block-size 2048 --efi-boot limine/BOOTX64.EFI \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        $TEMP -o $IMAGE_NAME

# Install Limine BIOS bootloader
$TEMP/limine/limine bios-install "$IMAGE_NAME"