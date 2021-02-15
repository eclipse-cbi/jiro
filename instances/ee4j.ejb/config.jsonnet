{
  project+: {
    fullName: "ee4j.ejb",
    displayName: "Jakarta Enterprise Beans"
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
