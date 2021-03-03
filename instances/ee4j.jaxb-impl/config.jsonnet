{
  project+: {
    fullName: "ee4j.jaxb-impl",
    displayName: "Eclipse Implementation of JAXB",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "envinject",
      "jacoco",
      "copyartifact",
    ],
  },
}
