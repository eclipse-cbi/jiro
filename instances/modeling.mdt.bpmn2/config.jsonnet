{
  project+: {
    fullName: "modeling.mdt.bpmn2",
    displayName: "Eclipse BPMN2"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c31,c0",
}
