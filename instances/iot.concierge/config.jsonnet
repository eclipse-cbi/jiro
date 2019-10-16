local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "iot.concierge",
    shortName: "concierge",
    displayName: "Eclipse Concierge"
  }
}
