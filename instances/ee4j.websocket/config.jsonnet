{
  project+: {
    fullName: "ee4j.websocket",
    displayName: "Jakarta Websocket",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
}
