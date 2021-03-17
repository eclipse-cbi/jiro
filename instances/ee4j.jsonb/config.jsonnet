{
  project+: {
    fullName: "ee4j.jsonb",
    displayName: "Jakarta JSON Binding",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  }
}
