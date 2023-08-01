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
  }
}
