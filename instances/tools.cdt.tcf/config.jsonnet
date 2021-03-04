{
  project+: {
    fullName: "tools.cdt.tcf",
    displayName: "Eclipse Target Communication Framework",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "warnings-ng",
    ]
  }
}
