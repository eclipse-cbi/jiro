{
  project+: {
    fullName: "tools.gef",
    displayName: "Eclipse GEF",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "copyartifact",
      "parameterized-scheduler",
      "slack",
    ],
  },
}
