{
  project+: {
    fullName: "automotive.openpass",
    displayName: "Eclipse openPASS",
    resourcePacks: 3
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
  },
  seLinuxLevel: "s0:c54,c4",
}
