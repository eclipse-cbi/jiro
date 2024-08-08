{
  project+: {
    fullName: "eclipse.equinox",
    displayName: "Eclipse Equinox",
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
}
