{
  project+: {
    fullName: "eclipse.equinox",
    displayName: "Eclipse Equinox",
    # remoteFSSuffix must be individual among all JIPPs which link the eclipse.platform.releng/jenkins/configuration.yml
    remoteFSSuffix: "equinox",
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "git-forensics",
      "mail-watcher-plugin",
    ],
  },
}
