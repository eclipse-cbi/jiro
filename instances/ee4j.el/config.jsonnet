{
  project+: {
    fullName: "ee4j.el",
    displayName: "Jakarta Expression Language"
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
