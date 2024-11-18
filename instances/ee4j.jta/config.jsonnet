{
  project+: {
    fullName: "ee4j.jta",
    displayName: "Jakarta Transactions",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c45,c10",
}
