{
  project+: {
    fullName: "tools.tm",
    displayName: "Eclipse Target Management",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
      "warnings-ng",
    ]
  }
}
