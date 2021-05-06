{
  project+: {
    fullName: "technology.rdf4j",
    displayName: "Eclipse RDF4J",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
}
