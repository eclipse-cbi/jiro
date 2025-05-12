{
  project+: {
    fullName: "technology.lsp4mp",
    displayName: "Eclipse LSP4MP",
  },
  jenkins+: {
    plugins+: [
      "blueocean",
      "embeddable-build-status",
    ],
  },
  seLinuxLevel: "s0:c47,c14",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
