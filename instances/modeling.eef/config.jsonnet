local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.eef",
    shortName: "eef",
    displayName: "Eclipse Extended Editing Framework"
  }
}
