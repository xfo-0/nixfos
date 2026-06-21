{ lib, ... }:
{
  den.aspects.kanso = {
    homeManager =
      { ... }:
      {
        stylix.base16Scheme = lib.mkDefault {
          name = "kanso-ink";
          slug = "kanso-ink";
          author = "custom";
          base00 = "000000";
          base01 = "1f1f26";
          base02 = "2a2a35";
          base03 = "5c6066";
          base04 = "75797f";
          base05 = "c5c9c7";
          base06 = "c5c9c7";
          base07 = "f2f1ef";
          base08 = "c4746e";
          base09 = "c4b28a";
          base0A = "c4b28a";
          base0B = "8a9a7b";
          base0C = "c5c9c7";
          base0D = "8ba4b0";
          base0E = "8992a7";
          base0F = "b6927b";
          base10 = "909398";
          base11 = "e46876";
          base12 = "87a987";
          base13 = "e6c384";
          base14 = "7fb4ca";
          base15 = "938aa9";
          base16 = "7aa89f";
          base17 = "c5c9c7";
        };
      };
  };
}
