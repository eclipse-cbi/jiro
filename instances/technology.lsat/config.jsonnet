{
  project+: {
    fullName: "technology.lsat",
    displayName: "Eclipse LSAT",
  },
  kubernetes+: {
    master+: {
      resources+: {
        memory+: {
          limit: "3072Mi",
          request: "1536Mi",
        },
      },
    },
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c58,c12",
}
