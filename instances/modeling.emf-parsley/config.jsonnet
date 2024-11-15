{
  project+: {
    fullName: "modeling.emf-parsley",
    displayName: "Eclipse EMF Parsley",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "mail-watcher-plugin",
      "warnings-ng",
    ],
  },
  seLinuxLevel: "s0:c38,c2",
}
