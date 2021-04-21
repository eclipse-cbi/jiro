{
  project+: {
    fullName: "technology.basyx",
    displayName: "Eclipse BaSyx",
  },
  jenkins+: {
    plugins+: [
      "envinject",
      "cmakebuilder",
      "gerrit-code-review",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
