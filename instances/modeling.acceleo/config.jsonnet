{
  project+: {
    fullName: "modeling.acceleo",
    displayName: "Eclipse Acceleo",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "warnings-ng",
    ],
  },
}
