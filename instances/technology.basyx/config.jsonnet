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
}
