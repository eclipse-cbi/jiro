{
  project+: {
    fullName: "modeling.acceleo",
    displayName: "Eclipse Acceleo",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "warnings-ng",
    ],
  },
}
