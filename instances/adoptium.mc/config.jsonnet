{
  project+: {
    fullName: "adoptium.mc",
    displayName: "Eclipse Mission Control",
  },
  jenkins+: {
    version: "2.361.4",
    plugins+: [
      "badge",
      "build-with-parameters",
      "embeddable-build-status",
      "groovy-postbuild",
      "http_request",
      "slack",
      "xvfb",
    ],
  },
}
