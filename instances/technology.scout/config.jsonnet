{
  project+: {
    fullName: "technology.scout",
    displayName: "Eclipse Scout",
  },
  jenkins+: {
    plugins+: [
      "job-dsl",
    ],
  },
  seLinuxLevel: "s0:c52,c49",
}
