{
  project+: {
    fullName: "ee4j.jaxrs",
    displayName: "Jakarta RESTful Web Services",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  }
}
