{
  project+: {
    fullName: "ee4j.jpa",
    displayName: "Jakarta Persistence",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
}
