local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ecd.orion",
    shortName: "orion",
    displayName: "Eclipse Orion"
  }
}
