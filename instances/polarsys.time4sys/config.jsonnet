local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "polarsys.time4sys",
    shortName: "time4sys",
    displayName: "Eclipse Time4Sys"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
