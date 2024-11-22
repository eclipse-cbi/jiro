{
  project+: {
    fullName: "dt.basyx",
    displayName: "Eclipse BaSyx",
  },
  jenkins+: {
    plugins+: [
      "envinject",
      "cmakebuilder",
      "gerrit-code-review",
    ],
  },
  seLinuxLevel: "s0:c30,c10",
}
