{
  project+: {
    fullName: "automotive.openpass",
    displayName: "Eclipse openPASS",
    resourcePacks: 2
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "mail-watcher-plugin",
      "conditional-buildstep",
    ],
  },
}
