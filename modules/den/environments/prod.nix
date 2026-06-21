{ lib, ... }:
let
  timezone = "America/Los_Angeles";

  lanCidr = "192.0.2.0/24";
  netBase =
    cidr:
    lib.concatStringsSep "." (lib.take 3 (lib.splitString "." (lib.head (lib.splitString "/" cidr))));
  gatewayIp = "${netBase lanCidr}.1";
  broadcast = "${netBase lanCidr}.255";

  assignments = {
    nl0x = "192.0.2.85";
    AO05 = "192.0.2.149";
    grpht = "192.0.2.62";
  };
  location = {
    country = "ZZ";
    region = "public";
  };
in
{
  den.environments.prod = {
    domain = "local";
    inherit timezone;
    inherit location;

    system-access-groups = [ "workstation-access" ];

    networks.lan = {
      cidr = lanCidr;
      inherit gatewayIp assignments;
    };

    settings = {
      core.timezone = timezone;
      network.wake-client.broadcast = broadcast;
      services.binary-cache.ncps.upstreamCaches = [ "https://cache.nixos.org" ];
      capabilities.persistent.enable = true;
      capabilities.workstation.enable = true;
    };
  };
}
