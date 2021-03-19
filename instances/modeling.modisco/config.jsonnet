{
  project+: {
    fullName: "modeling.modisco",
    displayName: "Eclipse MoDisco",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "buckminster",
    ],
  },
}
