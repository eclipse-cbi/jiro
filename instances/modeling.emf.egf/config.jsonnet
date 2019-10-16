local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emf.egf",
    shortName: "egf",
    displayName: "Eclipse Generation Factories"
  }
}
