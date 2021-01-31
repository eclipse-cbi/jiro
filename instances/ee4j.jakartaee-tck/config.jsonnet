{
  project+: {
    fullName: "ee4j.jakartaee-tck",
    displayName: "Eclipse Jakarta EE TCK",
    resourcePacks: 51,
  },
  jenkins+: {
    maxConcurrency: 25,
    agentConnectionTimeout: 300,
    theme: "quicksilver-light",
    plugins+: [
      "blueocean",
      "bootstraped-multi-test-results-report",
      "copyartifact",
      "description-setter",
      "envinject",
      "extended-choice-parameter",
      "groovy",
    ], 
  },
}
