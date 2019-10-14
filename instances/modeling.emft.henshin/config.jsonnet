local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emft.henshin",
    shortName: "henshin",
    displayName: "Eclipse Henshin"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
