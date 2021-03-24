{
  project+: {
    fullName: "modeling.mdt.uml2",
    displayName: "Eclipse MDT UML2",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "buckminster",
    ]
  }
}
