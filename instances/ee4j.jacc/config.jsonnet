{
  project+: {
    fullName: "ee4j.jacc",
    displayName: "Jakarta Authorizaion",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
