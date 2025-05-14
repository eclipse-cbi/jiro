{
  project+: {
    fullName: "ee4j.websocket",
    displayName: "Jakarta Websocket",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c57,c4",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
