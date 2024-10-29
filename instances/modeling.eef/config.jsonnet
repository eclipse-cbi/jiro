{
  project+: {
    fullName: "modeling.eef",
    displayName: "Eclipse Extended Editing Framework"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c36,c25",
}
