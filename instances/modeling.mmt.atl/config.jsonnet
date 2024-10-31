{
  project+: {
    fullName: "modeling.mmt.atl",
    displayName: "Eclipse ATL"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  },
  seLinuxLevel: "s0:c29,c19",
}
