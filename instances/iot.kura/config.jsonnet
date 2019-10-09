local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "iot.kura",
    shortName: "kura",
    displayName: "Eclipse Kura"
  }
}
