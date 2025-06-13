{
  project+: {
    fullName: "modeling.epsilon",
    displayName: "Eclipse Epsilon"
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
      "slack",
      "lockable-resources",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c38,c37",
}
