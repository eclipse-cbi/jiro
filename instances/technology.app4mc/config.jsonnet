local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.app4mc",
    shortName: "app4mc",
    displayName: "Eclipse APP4MC"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
