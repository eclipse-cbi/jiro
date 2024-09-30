{
  project+: {
    fullName: "ee4j.parsson",
    displayName: "Eclipse Parsson",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c51,c15",
}
