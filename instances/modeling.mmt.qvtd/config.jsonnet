local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mmt.qvtd",
    shortName: "qvtd",
    displayName: "Eclipse QVTd"
  },
  jenkins+: {
    theme: "quicksilver-light"
  }
}
