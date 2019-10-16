local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "rt.ebr",
    shortName: "ebr",
    displayName: "Eclipse Bundle Recipes"
  }
}
