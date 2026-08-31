{
  project+: {
    fullName: "iot.kura",
    displayName: "Eclipse Kura"
  },
  kubernetes+: {
    master+: {
      resources+: {
        memory+: {
          limit: "2048Mi",
          request: "2048Mi",
        },
      },
    },
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
