local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.jgit",
    shortName: "jgit",
    displayName: "Eclipse JGit",
    "sponsorshipLevel": "S1"
  },
  jenkins: {
    maxConcurrency: 4,
    theme: "quicksilver-light"
  }
}
