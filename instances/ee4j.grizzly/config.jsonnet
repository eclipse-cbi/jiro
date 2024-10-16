{
  project+: {
    fullName: "ee4j.grizzly",
    displayName: "Eclipse Grizzly",
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c41,c15",
}
