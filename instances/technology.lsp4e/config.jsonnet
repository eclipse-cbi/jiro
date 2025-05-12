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
  seLinuxLevel: "s0:c47,c4",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
