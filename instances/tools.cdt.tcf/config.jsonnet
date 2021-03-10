{
  project+: {
    fullName: "tools.cdt.tcf",
    displayName: "Eclipse Target Communication Framework",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "warnings-ng",
    ]
  }
}
