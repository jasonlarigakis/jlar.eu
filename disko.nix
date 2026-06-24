# Disk layout for this host, expressed in disko's schema.
#
# This mirrors the existing on-disk layout of /dev/sda (a single QEMU disk with
# an MBR/msdos partition table, BIOS GRUB, and three partitions):
#
#   sda1  512M  ext4   label=boot   -> /boot   (bootable)
#   sda2  ~8G   swap   label=swap
#   sda3  rest  ext4   label=nixos  -> /
#
# Because the disk uses an MBR partition table (not GPT), we use disko's legacy
# `table` type with `format = "msdos"`. The modern `gpt` type would require
# converting to a GPT layout and adding a BIOS boot partition, which is a
# different on-disk layout than what is currently deployed.
#
# Filesystem labels are created via `extraArgs` so the /dev/disk/by-label/*
# symlinks remain available for recovery / manual mounting, matching the
# previous hand-written configuration.
{ ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "msdos";

        partitions = [
          {
            name = "boot";
            part-type = "primary";
            fs-type = "ext4";
            start = "1MiB";
            end = "513MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
              mountOptions = [ "defaults" ];
              extraArgs = [ "-L" "boot" ];
            };
          }
          {
            name = "swap";
            part-type = "primary";
            fs-type = "linux-swap";
            start = "513MiB";
            end = "8705MiB";
            content = {
              type = "swap";
              extraArgs = [ "-L" "swap" ];
            };
          }
          {
            name = "nixos";
            part-type = "primary";
            fs-type = "ext4";
            start = "8705MiB";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
              extraArgs = [ "-L" "nixos" ];
            };
          }
        ];
      };
    };
  };
}
