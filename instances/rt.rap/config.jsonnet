{
  project+: {
    fullName: "rt.rap",
    displayName: "Eclipse RAP",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
