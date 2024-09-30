{
  project+: {
    fullName: "ee4j.jca",
    displayName: "Jakarta Connectors",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c43,c32",
}
