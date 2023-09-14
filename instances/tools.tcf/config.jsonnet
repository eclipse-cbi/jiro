{
  project+: {
    fullName: "tools.tcf",
    displayName: "Eclipse Target Communication Framework",
    unixGroupName: "tools.cdt.tcf",
  },
  jenkins+: {
    version: "2.414.1",
    plugins+: [
      "gerrit-trigger",
      "warnings-ng",
    ]
  }
}
