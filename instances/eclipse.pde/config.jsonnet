{
  project+: {
    fullName: "eclipse.pde",
    displayName: "Eclipse Plugin Development Environment (PDE)"
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
