{
  project+: {
    fullName: "automotive.openpass",
    displayName: "Eclipse openPASS",
    resourcePacks: 3
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "conditional-buildstep",
    ],
  },
}
