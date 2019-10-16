local default = import '../../templates/config.libsonnet';

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
