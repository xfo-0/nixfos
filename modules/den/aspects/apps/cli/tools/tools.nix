{ den, ... }:
{
  den.aspects.cli.tools.includes = [
    den.aspects.cli.tools.archive-tools
    den.aspects.cli.tools.cli-tools
    den.aspects.cli.tools.herdr
    den.aspects.cli.tools.sys-tools
  ];
}
