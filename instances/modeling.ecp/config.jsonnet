{
  project+: {
    fullName: "modeling.ecp",
    displayName: "Eclipse EMF Client Platform",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  seLinuxLevel: "s0:c36,c10",
}
