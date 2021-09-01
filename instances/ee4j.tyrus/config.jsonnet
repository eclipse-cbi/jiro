{
  project+: {
    fullName: "ee4j.tyrus",
    displayName: "Eclipse Tyrus",
  },
  maven+: {
    showVersion: false,
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
}
