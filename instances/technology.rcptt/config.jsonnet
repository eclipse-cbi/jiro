local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.rcptt",
    shortName: "rcptt",
    displayName: "Eclipse RCP Testing Tool"
  }
}
