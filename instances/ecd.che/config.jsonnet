local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ecd.che",
    shortName: "che",
    displayName: "Eclipse Che"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
