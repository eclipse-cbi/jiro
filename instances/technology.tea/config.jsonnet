local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.tea",
    shortName: "tea",
    displayName: "Eclipse TEA"
  }
}
