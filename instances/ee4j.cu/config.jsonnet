{
  project+: {
    fullName: "ee4j.cu",
    displayName: "Jakarta Concurrency"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c34,c4",
}
