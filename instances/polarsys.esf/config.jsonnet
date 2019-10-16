local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "polarsys.esf",
    shortName: "esf",
    displayName: "Eclipse Safety Framework"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
