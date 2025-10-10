{
  project+: {
    fullName: "iot.4diac",
    displayName: "Eclipse 4diac",
  },
  jenkins+: {
    staticAgentCount: 2, //trying to fix Java Heap Space issue - hd#6556
    plugins+: [
      "cmakebuilder",
      "copyartifact",
      "embeddable-build-status",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c28,c7",
}
