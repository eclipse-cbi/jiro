{
  project+: {
    fullName: "ee4j.faces",
    displayName: "Jakarta Server Faces"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c39,c29",
}
