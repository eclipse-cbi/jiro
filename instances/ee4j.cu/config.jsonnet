{
  project+: {
    fullName: "ee4j.cu",
    displayName: "Jakarta Concurrency"
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
