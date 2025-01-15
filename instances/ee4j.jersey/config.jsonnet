{
  project+: {
    fullName: "ee4j.jersey",
    displayName: "Eclipse Jersey",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c44,c4",
}
