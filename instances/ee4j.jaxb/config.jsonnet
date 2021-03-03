{
  project+: {
    fullName: "ee4j.jaxb",
    displayName: "Jakarta XML Binding",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  }
}
