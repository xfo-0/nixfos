let
  sn750 = "/dev/disk/by-id/REPLACE_SN750";
  sn770 = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_22152X802959";
in
{
  disko.devices = {
    disk = {
      data-sn750 = {
        device = sn750;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            NIXOS = {
              size = "100%";
            };
          };
        };
      };

      root-sn770 = {
        device = sn770;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
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
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            NIXOS = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L NIXOS"
                  "-f"
                  "-d raid0"
                  "-m raid1"
                  "${sn750}-part1"
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
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                    ];
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
