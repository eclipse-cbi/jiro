{
  project+: {
    fullName: "iot.kura",
    displayName: "Eclipse Kura"
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "clone-workspace-scm",
      "jacoco",
      "junit-attachments",
    ],
  },
}
