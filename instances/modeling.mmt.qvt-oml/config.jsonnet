{
  project+: {
    fullName: "modeling.mmt.qvt-oml",
    displayName: "Eclipse QVT Operational"
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
