local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "iot.concierge",
    shortName: "concierge",
    displayName: "Eclipse Concierge"
  }
}
