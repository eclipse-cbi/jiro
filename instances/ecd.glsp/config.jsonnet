{
  project+: {
    fullName: "ecd.glsp",
    displayName: "Eclipse GLSP",
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "github-checks",
      "embeddable-build-status",
      "htmlpublisher",
    ],
  },
}
