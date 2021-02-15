{
  project+: {
    fullName: "iot.kura",
    displayName: "Eclipse Kura"
  },
  jenkins+: {
    plugins+: [
      "clone-workspace-scm",
      "jacoco",
      "junit-attachments",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
