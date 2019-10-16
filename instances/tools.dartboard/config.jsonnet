local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.dartboard",
    shortName: "dartboard",
    displayName: "Eclipse Dartboard"
  }
}
