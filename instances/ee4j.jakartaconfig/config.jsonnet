{
  project+: {
    fullName: "ee4j.jakartaconfig",
    displayName: "Jakarta Config",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c56,c35",
}
