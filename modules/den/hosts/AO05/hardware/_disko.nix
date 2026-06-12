{
  disko.devices = {
    disk = {
      WD-BLACK-SN770-1TB = {
        device = "/dev/disk/by-id/REPLACE_WITH_HOST_DISK";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # Boot
            ESP = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            NIXOS = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L NIXOS"
                  "-f"
                ];
                subvolumes = {
                  "nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                    ];
                  };
                  "log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                    ];
                  };
                  "persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                    ];
                  };
                  "home" = {
                    mountpoint = "/persist/home";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                    ];
                  };
                  "swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "64G";
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=755"
        "size=50%"
        "noatime"
      ];
    };
  };
}
