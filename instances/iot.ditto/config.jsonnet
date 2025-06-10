{
  project+: {
    fullName: "iot.ditto",
    displayName: "Eclipse Ditto",
  },
  jenkins+: {
    plugins+: [
      "nodejs",
      "pipeline-utility-steps",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c34,c29",
}
