local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emf.mwe",
    shortName: "mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  }
}
