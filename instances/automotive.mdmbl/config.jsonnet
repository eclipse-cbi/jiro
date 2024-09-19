{
  project+: {
    fullName: "automotive.mdmbl",
    displayName: "Eclipse MDM|BL",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "gradle",
    ]
  },
  seLinuxLevel: "s0:c47,c44",
}
