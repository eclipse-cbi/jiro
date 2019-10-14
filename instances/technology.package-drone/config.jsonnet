local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.package-drone",
    shortName: "package-drone",
    displayName: "Eclipse Package Drone"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
