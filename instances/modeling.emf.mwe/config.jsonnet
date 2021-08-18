{
  project+: {
    fullName: "modeling.emf.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  jenkins+: {
    plugins+: [
      "slack",
      "parameterized-scheduler",
    ],
  },
}
