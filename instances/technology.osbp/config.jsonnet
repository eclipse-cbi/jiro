local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.osbp",
    shortName: "osbp",
    displayName: "Eclipse Open Standard Business Platform"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
