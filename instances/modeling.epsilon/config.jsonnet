local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.epsilon",
    shortName: "epsilon",
    displayName: "Eclipse Epsilon"
  }
}
