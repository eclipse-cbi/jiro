{
  project+: {
    fullName: "eclipse.jdt",
    displayName: "Eclipse Java Development Tools (JDT)",
    resourcePacks: 3,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
}
