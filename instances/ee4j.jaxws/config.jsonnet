{
  project+: {
    fullName: "ee4j.jaxws",
    displayName: "Jakarta XML Web Services",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "envinject",
    ],
  },
}
