{
  project+: {
    fullName: "ee4j.yasson",
    displayName: "Eclipse Yasson",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c57,c54",
}
