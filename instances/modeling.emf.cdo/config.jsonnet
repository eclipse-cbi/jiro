{
  project+: {
    fullName: "modeling.emf.cdo",
    displayName: "Eclipse CDO Model Repository",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "mail-watcher-plugin",
      "zentimestamp",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
