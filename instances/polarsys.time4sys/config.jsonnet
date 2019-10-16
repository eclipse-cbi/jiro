local default = import '../../templates/config.libsonnet';

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
