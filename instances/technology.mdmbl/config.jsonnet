{
  project+: {
    fullName: "technology.mdmbl",
    displayName: "Eclipse MDM|BL",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ]
  }
}
