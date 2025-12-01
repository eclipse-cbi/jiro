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
      "pipeline-utility-steps",
    ],
  },
  seLinuxLevel: "s0:c46,c20",
}
