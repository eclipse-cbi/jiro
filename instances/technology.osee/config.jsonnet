{
  project+: {
    fullName: "technology.osee",
    displayName: "Eclipse OSEE"
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "nodejs",
    ],
  },
}
