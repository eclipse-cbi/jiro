{
  project+: {
    fullName: "iot.tahu",
    displayName: "Eclipse Tahu",
  },
  jenkins+: {
    plugins+: [
      "maven-plugin",
    ],
  },
  seLinuxLevel: "s0:c58,c32",
}
