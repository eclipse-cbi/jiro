{
  project+: {
    fullName: "ee4j.jca",
    displayName: "Jakarta Connectors",
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
