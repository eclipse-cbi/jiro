local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ecd.codewind",
    shortName: "codewind",
    displayName: "Eclipse Codewind",
    "sponsorshipLevel": "S2"
  },
  jenkins: {
    maxConcurrency: 6
  }
}
