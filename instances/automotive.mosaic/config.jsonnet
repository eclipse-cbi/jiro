{
  project+: {
    fullName: "automotive.mosaic",
    displayName: "Eclipse Mosaic",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
}
