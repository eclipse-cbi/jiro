local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mdt.rmf",
    shortName: "rmf",
    displayName: "Eclipse RMF"
  }
}
