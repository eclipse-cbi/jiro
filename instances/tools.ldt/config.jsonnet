local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.ldt",
    shortName: "ldt",
    displayName: "Eclipse Lua Development Tools"
  }
}
