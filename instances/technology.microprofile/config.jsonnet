local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.microprofile",
    shortName: "microprofile",
    displayName: "Eclipse MicroProfile"
  },
  deployment: {
    host: "ci-staging.eclipse.org"
  }
}
