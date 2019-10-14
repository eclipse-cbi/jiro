local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.sensinact",
    shortName: "sensinact",
    displayName: "Eclipse sensiNact"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
