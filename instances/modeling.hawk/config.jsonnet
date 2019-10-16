local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.hawk",
    shortName: "hawk",
    displayName: "Eclipse Hawk"
  }
}
