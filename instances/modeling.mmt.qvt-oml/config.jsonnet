local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mmt.qvt-oml",
    shortName: "qvt-oml",
    displayName: "Eclipse QVT Operational"
  },
  jenkins+: {
    theme: "quicksilver-light"
  }
}
