{
  project+: {
    fullName: "ee4j.jpa",
    displayName: "Jakarta Persistence",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c44,c29",
}
