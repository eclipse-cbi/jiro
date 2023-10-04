{
  project+: {
    fullName: "tools.tcf",
    displayName: "Eclipse Target Communication Framework",
    unixGroupName: "tools.cdt.tcf",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "warnings-ng",
    ]
  }
}
