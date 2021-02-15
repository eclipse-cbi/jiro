{
  project+: {
    fullName: "ee4j.ca",
    displayName: "Jakarta Annotations"
  },
  jenkins+: {
    plugins: [
      "copyartifact",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
