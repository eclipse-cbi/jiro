{
  project+: {
    fullName: "ecd.glsp",
    displayName: "Eclipse GLSP",
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "embeddable-build-status",
      "htmlpublisher",
    ],
  },
}
