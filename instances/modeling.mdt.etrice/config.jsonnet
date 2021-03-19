{
  project+: {
    fullName: "modeling.mdt.etrice",
    displayName: "Eclipse eTrice"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "gradle",
      "postbuild-task",
    ],
  },
  gradle+: {
    generate: true,
  }
}
