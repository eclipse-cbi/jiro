local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.ptp",
    shortName: "ptp",
    displayName: "Eclipse PTP"
  }
}
