{
  project+: {
    fullName: "eclipse.pde",
    displayName: "Eclipse Plugin Development Environment (PDE)"
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
}
