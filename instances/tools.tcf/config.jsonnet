{
  project+: {
    fullName: "tools.tcf",
    displayName: "Eclipse Target Communication Framework",
    unixGroupName: "tools.cdt.tcf",
  },
  jenkins+: {
    plugins+: [
      "warnings-ng",
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c55,c5",
}
