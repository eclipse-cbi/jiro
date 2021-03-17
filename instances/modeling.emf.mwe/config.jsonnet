{
  project+: {
    fullName: "modeling.emf.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins: [
      "slack",
      "parameterized-scheduler",
    ],
  },
}
