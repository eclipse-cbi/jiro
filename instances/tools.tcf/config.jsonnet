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
  },
  seLinuxLevel: "s0:c55,c5",
}
