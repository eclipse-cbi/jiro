{
  project+: {
    fullName: "technology.dltk",
    displayName: "Eclipse Dynamic Languages Toolkit"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c57,c4",
}
