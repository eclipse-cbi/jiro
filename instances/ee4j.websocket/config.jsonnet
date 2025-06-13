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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c57,c4",
}
