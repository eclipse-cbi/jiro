local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.keti",
    shortName: "keti",
    displayName: "Eclipse Keti"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
