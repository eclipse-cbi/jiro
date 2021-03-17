{
  project+: {
    fullName: "ee4j.servlet",
    displayName: "Jakarta Servlet",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
}
