local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.jnosql",
    shortName: "jnosql",
    displayName: "Eclipse JNoSQL"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
