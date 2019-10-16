local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.actf",
    shortName: "actf",
    displayName: "Eclipse ACTF"
  }
}
