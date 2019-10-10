local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.egit",
    shortName: "egit",
    displayName: "Eclipse EGit",
    sponsorshipLevel: "S1",
    resourcePacks: 2,
  },
  jenkins+: {
    theme: "quicksilver-light"
  }
}
