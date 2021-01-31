{
  project+: {
    fullName: "modeling.emfcompare",
    displayName: "Eclipse EMF Compare",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
