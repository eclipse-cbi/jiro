{
  project+: {
    fullName: "tools.tm",
    displayName: "Eclipse Target Management",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
      "gerrit-trigger",
      "warnings-ng",
    ]
  }
}
