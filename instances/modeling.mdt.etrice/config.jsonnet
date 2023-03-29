{
  project+: {
    fullName: "modeling.mdt.etrice",
    displayName: "Eclipse eTrice"
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "gradle",
      "postbuild-task",
    ],
  },
  gradle+: {
    generate: true,
  }
}
