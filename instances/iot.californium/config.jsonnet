local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.californium",
    shortName: "californium",
    displayName: "Eclipse Californium"
  }
}
