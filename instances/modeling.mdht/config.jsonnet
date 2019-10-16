local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mdht",
    shortName: "mdht",
    displayName: "Eclipse Model Driven Health Tools"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
