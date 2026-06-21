{
  config,
  inputs,
  den,
  ...
}:
{
  imports = [
    (inputs.den.flakeModules.default or { })
  ];

  _module.args.__findFile = den.lib.__findFile;

  systems = config.den.systems;
  den.default.includes = [
    den.batteries.inputs'
    den.batteries.self'
    den.aspects.core.default
  ];
}
