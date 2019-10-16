local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.acute",
    shortName: "acute",
    displayName: "Eclipse aCute"
  }
}
