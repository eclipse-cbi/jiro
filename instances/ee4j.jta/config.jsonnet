{
  project+: {
    fullName: "ee4j.jta",
    displayName: "Jakarta Transactions",
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
