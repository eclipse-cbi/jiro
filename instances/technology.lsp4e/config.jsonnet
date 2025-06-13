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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c47,c4",
}
