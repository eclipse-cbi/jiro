{
  project+: {
    fullName: "modeling.mdt.uml2",
    displayName: "Eclipse MDT UML2",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "buckminster",
    ]
  }
}
