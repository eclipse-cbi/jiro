local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "tools.ptp",
    shortName: "ptp",
    displayName: "Eclipse PTP"
  }
}
