{
  project+: {
    fullName: "technology.lsp4e",
    displayName: "Eclipse LSP4E",
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
