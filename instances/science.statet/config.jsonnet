{
  project+: {
    fullName: "science.statet",
    displayName: "StatET"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  },
  seLinuxLevel: "s0:c54,c24",
}
