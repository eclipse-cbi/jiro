local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.gemoc",
    shortName: "gemoc",
    displayName: "Eclipse GEMOC Studio"
  }
}
