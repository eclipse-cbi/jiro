{
  project+: {
    fullName: "technology.lsp4j",
    displayName: "Eclipse LSP4J",
  },
  jenkins+: {
    plugins+: [
      "gradle",
      "matrix-communication"
    ]
  },
  seLinuxLevel: "s0:c47,c9",
}
