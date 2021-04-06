{
  project+: {
    fullName: "modeling.emf-parsley",
    displayName: "Eclipse EMF Parsley",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "warnings-ng",
    ],
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  }
}
