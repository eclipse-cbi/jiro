local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.recommenders",
    shortName: "recommenders",
    displayName: "Eclipse Code Recommenders"
  }
}
