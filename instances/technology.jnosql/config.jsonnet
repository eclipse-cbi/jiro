local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.jnosql",
    shortName: "jnosql",
    displayName: "Eclipse JNoSQL"
  },
  deployment: {
    host: "ci-staging.eclipse.org"
  }
}
