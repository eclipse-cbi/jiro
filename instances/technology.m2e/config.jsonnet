local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.m2e",
    shortName: "m2e",
    displayName: "Eclipse Maven Integration"
  }
}
