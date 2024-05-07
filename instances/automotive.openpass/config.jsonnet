{
  project+: {
    fullName: "automotive.openpass",
    displayName: "Eclipse openPASS",
    resourcePacks: 5
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "nodejs",
      "conditional-buildstep",
    ],
  },
  kubernetes+: {
    master+: {
      defaultJnlpAgentLabel: "basic-ubuntu",
    }
  }
}
