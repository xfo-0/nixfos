let
  nvme0 = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_4TB_S7DSNJ0Y301169F";
  nvme1 = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_with_Heatsink_4TB_S7DSNJ0Y301172W";
  mediaHdd = "/dev/disk/by-id/ata-ST26000DM000-3Y8103_ZXA0XSXK";
in
{
  disko.devices = {
    disk = {
      nvme-root = {
        device = nvme0;
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
              size = "32G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
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
                  "${nvme1}-part1"
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

      nvme-data = {
        device = nvme1;
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

      media = {
        device = mediaHdd;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            DATA = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/data";
                mountOptions = [ "noatime" ];
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
