{
  project+: {
    fullName: "eclipse.jdt",
    displayName: "Eclipse Java Development Tools (JDT)",
    resourcePacks: 3,
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
}
