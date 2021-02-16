{
  project+: {
    fullName: "technology.lsp4j",
    displayName: "Eclipse LSP4J",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ]
  }
}
