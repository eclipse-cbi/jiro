{
  project+: {
    fullName: "iot.kapua",
    displayName: "Eclipse Kapua",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "htmlpublisher",
      "nodejs"
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c45,c30",
}
