local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.amalgam",
    shortName: "amalgam",
    displayName: "Eclipse Amalgamation"
  }
}
