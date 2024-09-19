{
  project+: {
    fullName: "automotive.mosaic",
    displayName: "Eclipse Mosaic",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  seLinuxLevel: "s0:c48,c32",
}
