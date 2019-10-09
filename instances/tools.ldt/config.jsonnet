local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "tools.ldt",
    shortName: "ldt",
    displayName: "Eclipse Lua Development Tools"
  }
}
