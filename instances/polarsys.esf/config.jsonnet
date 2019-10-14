local default = import '../../templates/default.libsonnet';

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
