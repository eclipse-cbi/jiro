{
  project+: {
    fullName: "technology.rdf4j",
    displayName: "Eclipse RDF4J",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c52,c19",
}
