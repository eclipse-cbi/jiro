{
  project+: {
    fullName: "technology.lsat",
    displayName: "Eclipse LSAT",
  },
  kubernetes+: {
    master+: {
      resources+: {
        memory+: {
          limit: "2048Mi",
          request: "2048Mi",
        },
      },
    },
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c58,c12",
}
