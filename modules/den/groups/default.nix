{
  den.groups = {
    admins = {
      labels = [ "user-role" ];
      description = "Full administrative access";
    };
    users = {
      labels = [ "user-role" ];
      description = "Standard user access";
      members = [ "admins" ];
    };

    system-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 951;
      description = "Login access to all hosts";
    };
    workstation-access = {
      labels = [
        "user-role"
        "posix"
      ];
      gid = 950;
      description = "Login access to workstation hosts";
      members = [ "system-access" ];
    };

    wheel = {
      labels = [ "posix" ];
      gid = 10;
      description = "Sudo access";
      members = [ "workstation-access" ];
    };
    audio = {
      labels = [ "posix" ];
      gid = 63;
      description = "Audio device access";
      members = [ "workstation-access" ];
    };
    video = {
      labels = [ "posix" ];
      gid = 44;
      description = "Video device access";
      members = [ "workstation-access" ];
    };
    render = {
      labels = [ "posix" ];
      gid = 106;
      description = "GPU render access";
      members = [ "workstation-access" ];
    };
    input = {
      labels = [ "posix" ];
      gid = 40;
      description = "Input device access";
      members = [ "workstation-access" ];
    };
    networkmanager = {
      labels = [ "posix" ];
      gid = 84;
      description = "NetworkManager control";
      members = [ "workstation-access" ];
    };
    podman = {
      labels = [ "posix" ];
      gid = 993;
      description = "Container runtime access";
      members = [ "workstation-access" ];
    };
    libvirtd = {
      labels = [ "posix" ];
      gid = 901;
      description = "VM management access";
    };
    kvm = {
      labels = [ "posix" ];
      gid = 902;
      description = "KVM hypervisor access";
    };
  };
}
