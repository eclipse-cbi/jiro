{
  project+: {
    fullName: "ee4j.ca",
    displayName: "Jakarta Annotations"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c31,c5",
}
