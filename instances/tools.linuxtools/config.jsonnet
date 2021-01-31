{
  project+: {
    fullName: "tools.linuxtools",
    displayName: "Eclipse Linux Tools"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
