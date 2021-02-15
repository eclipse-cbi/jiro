{
  project+: {
    fullName: "ee4j.faces",
    displayName: "Jakarta Server Faces"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
