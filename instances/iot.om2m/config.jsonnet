local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.om2m",
    shortName: "om2m",
    displayName: "Eclipse OM2M"
  }
}
