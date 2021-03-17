{
  project+: {
    fullName: "ee4j.jsonp",
    displayName: "Jakarta JSON Processing",
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
