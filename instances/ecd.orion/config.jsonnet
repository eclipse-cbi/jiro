local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ecd.orion",
    shortName: "orion",
    displayName: "Eclipse Orion"
  }
}
