{ den, lib, ... }:
{
  den.aspects.network.hardening = {
    includes = [
      den.aspects.network.hardening.firewall
      den.aspects.network.hardening.sysctl
      den.aspects.network.hardening.ssh
    ];

    firewall.nixos = {
      services.openssh.openFirewall = false;
      networking.firewall.checkReversePath = "loose";
    };

    sysctl.nixos = {
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.all.log_martians" = 1;
        "net.ipv4.conf.default.log_martians" = 1;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
      };
    };

    ssh.nixos = {
      services.openssh.settings = {
        MaxAuthTries = lib.mkDefault 3;
        LoginGraceTime = lib.mkDefault 30;
        KexAlgorithms = lib.mkDefault [
          "sntrup761x25519-sha512@openssh.com"
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
        ];
        Ciphers = lib.mkDefault [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
        ];
        Macs = lib.mkDefault [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
        ];
      };
    };
  };
}
