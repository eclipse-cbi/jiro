local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.kura",
    shortName: "kura",
    displayName: "Eclipse Kura"
  }
}
