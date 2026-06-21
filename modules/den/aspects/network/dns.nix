{ ... }:
{
  den.aspects.dns = {
    nixos = {
      services.resolved = {
        enable = true;
        settings.Resolve.DNSOverTLS = true;
      };
      networking.nameservers = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
        "2606:4700:4700::1111#cloudflare-dns.com"
        "2606:4700:4700::1001#cloudflare-dns.com"
      ];
      networking.dhcpcd.extraConfig = "nooption domain_name_servers, domain_name, domain_search";
    };
  };
}
