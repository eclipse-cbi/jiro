{
  project+: {
    fullName: "ee4j.jsp",
    displayName: "Jakarta Server Pages",
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
