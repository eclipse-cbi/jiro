{
  project+: {
    fullName: "ee4j.websocket",
    displayName: "Jakarta Websocket",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c57,c4",
}
