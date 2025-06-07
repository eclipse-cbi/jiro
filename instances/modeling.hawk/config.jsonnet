{
  project+: {
    fullName: "modeling.hawk",
    displayName: "Eclipse Hawk"
  },
  jenkins+: {
    plugins+: [
      "lockable-resources",
      "slack",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c41,c25",
}
