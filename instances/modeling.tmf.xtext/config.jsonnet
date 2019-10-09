local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "modeling.tmf.xtext",
    shortName: "xtext",
    displayName: "Eclipse Xtext",
    "sponsorshipLevel": "S1"
  },
  jenkins: {
    maxConcurrency: 4
  }
}
