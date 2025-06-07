{
  project+: {
    fullName: "ee4j.exousia",
    displayName: "Eclipse Exousia",
  },
  jenkins+: {
    plugins+: [
      "envinject"
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c36,c25",
}
