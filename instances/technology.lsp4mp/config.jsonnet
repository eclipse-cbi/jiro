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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c47,c14",
}
