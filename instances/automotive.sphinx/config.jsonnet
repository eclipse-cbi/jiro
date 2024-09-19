{
  project+: {
    fullName: "automotive.sphinx",
    displayName: "Eclipse Sphinx",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  },
  seLinuxLevel: "s0:c54,c9",
}
