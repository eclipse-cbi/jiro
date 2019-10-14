local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "polarsys.polarsys.chess",
    shortName: "chess",
    displayName: "Eclipse Chess"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
