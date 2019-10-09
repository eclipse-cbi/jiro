local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.openk-platform",
    shortName: "openk-platform",
    displayName: "Eclipse openK platform"
  },
  deployment: {
    host: "ci-staging.eclipse.org"
  }
}
