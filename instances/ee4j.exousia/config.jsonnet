{
  project+: {
    fullName: "ee4j.exousia",
    displayName: "Eclipse Exousia",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "envinject"
    ]
  },
}
