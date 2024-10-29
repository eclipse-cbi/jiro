{
  project+: {
    fullName: "modeling.modisco",
    displayName: "Eclipse MoDisco",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "gerrit-trigger",
    ],
  },
  seLinuxLevel: "s0:c48,c22",
}
