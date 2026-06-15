let
  nvme0 = "/dev/disk/by-id/REPLACE_990PRO_A";
  nvme1 = "/dev/disk/by-id/REPLACE_990PRO_B";
in
{
  disko.devices = {
    disk = {
      nvme0 = {
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

      nvme1 = {
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
