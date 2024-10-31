{
  project+: {
    fullName: "iot.zenoh",
    displayName: "Eclipse zenoh",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
    ],
  },
  seLinuxLevel: "s0:c58,c2",
}
