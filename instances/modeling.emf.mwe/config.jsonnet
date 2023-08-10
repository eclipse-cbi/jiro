{
  project+: {
    fullName: "modeling.emf.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  jenkins+: {
    version: "2.387.3",
    plugins+: [
      "slack",
      "parameterized-scheduler",
      "matrix-communication",
      "maven-plugin"
    ],
  },
}
