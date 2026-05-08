{
  project+: {
    fullName: "modeling.ocl",
    displayName: "Eclipse OCL"
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact"
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c49,c34",
}
