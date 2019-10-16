local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.vorto",
    shortName: "vorto",
    displayName: "Eclipse Vorto"
  }
}
