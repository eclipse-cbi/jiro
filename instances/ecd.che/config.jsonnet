local default = import '../../templates/default.libsonnet';

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
