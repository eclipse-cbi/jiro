local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "tools.tracecompass",
    shortName: "tracecompass",
    displayName: "Eclipse Trace Compass"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
