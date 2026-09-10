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
    staticAgentCount: 2,
  },
  seLinuxLevel: "s0:c46,c20",
}
