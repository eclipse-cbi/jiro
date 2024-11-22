{
  project+: {
    fullName: "automotive.mdmbl",
    displayName: "Eclipse MDM|BL",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ]
  },
  seLinuxLevel: "s0:c47,c44",
}
