{
  project+: {
    fullName: "modeling.emf.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  jenkins+: {
    version: "2.414.1",
    plugins+: [
      "parameterized-scheduler",
      "matrix-communication",
    ],
  },
}
