{
  project+: {
    fullName: "ee4j.jaf",
    displayName: "Jakarta Activation",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
