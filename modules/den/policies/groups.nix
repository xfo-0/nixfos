{
  den,
  inputs,
  ...
}:
let
  schemaLib = inputs.gen-schema.lib;
in
{
  options.den.groups = schemaLib.mkInstanceRegistry den.schema.group {
    description = "Group definitions for access policy resolution";
  };
}
