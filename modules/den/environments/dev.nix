{
  den.environments.dev = {
    domain = "dev.local";
    timezone = "America/Los_Angeles";

    system-access-groups = [ "workstation-access" ];

    location = {
      country = "ZZ";
      region = "dev";
    };

    settings.capabilities = {
      persistent.enable = true;
      workstation.enable = true;
    };
  };
}
