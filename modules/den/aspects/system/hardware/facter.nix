{ ... }:
{
  den.aspects.facter = facterReportPath: {
    nixos.hardware.facter.reportPath = facterReportPath;
  };
}
