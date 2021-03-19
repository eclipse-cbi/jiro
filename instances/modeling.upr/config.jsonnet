{
  project+: {
    fullName: "modeling.upr",
    displayName: "Eclipse UML Profiles Repository",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
}
