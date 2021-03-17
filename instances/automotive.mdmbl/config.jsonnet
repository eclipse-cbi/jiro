{
  project+: {
    fullName: "automotive.mdmbl",
    displayName: "Eclipse MDM|BL",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ]
  }
}
