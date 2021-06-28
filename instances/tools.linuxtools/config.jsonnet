{
  project+: {
    fullName: "tools.linuxtools",
    displayName: "Eclipse Linux Tools"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "build-with-parameters"
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
