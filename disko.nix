# Declarative disk layout for these Hetzner CX hosts (legacy BIOS boot, GPT).
#
# disko OWNS partitioning + formatting only. `disko.enableConfig = false` keeps
# the running system's mount config in configuration.nix (mounting by filesystem
# label), so a plain `nixos-rebuild switch` on the existing hosts is unaffected.
# The labels created here (boot / swap / nixos) match those fileSystems entries,
# so a from-scratch install mounts correctly.
#
# Provision a fresh machine (booted into the NixOS installer) with:
#   nix run github:nix-community/disko -- --mode disko --flake .#enki ./disko.nix
#   nixos-install --flake .#enki --no-root-passwd
{
  disko.enableConfig = false;

  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {
        # BIOS boot partition: GRUB embeds core.img here on GPT + legacy BIOS.
        bios = {
          size = "1M";
          type = "EF02";
        };
        boot = {
          size = "1G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/boot";
            extraArgs = [ "-L" "boot" ];
          };
        };
        swap = {
          size = "4G";
          content = {
            type = "swap";
            extraArgs = [ "-L" "swap" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            extraArgs = [ "-L" "nixos" ];
          };
        };
      };
    };
  };
}
