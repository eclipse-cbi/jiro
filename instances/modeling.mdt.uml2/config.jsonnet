{
  project+: {
    fullName: "modeling.mdt.uml2",
    displayName: "Eclipse MDT UML2",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c56,c20",
}
