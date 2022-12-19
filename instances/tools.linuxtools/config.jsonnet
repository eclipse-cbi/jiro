{
  project+: {
    fullName: "tools.linuxtools",
    displayName: "Eclipse Linux Tools"
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "jacoco",
      "build-with-parameters"
    ],
  },
}
