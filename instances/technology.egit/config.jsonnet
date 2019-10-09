local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.egit",
    shortName: "egit",
    displayName: "Eclipse EGit",
    "sponsorshipLevel": "S1"
  },
  jenkins: {
    maxConcurrency: 4,
    theme: "quicksilver-light"
  }
}
