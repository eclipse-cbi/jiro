{
  project+: {
    fullName: "ee4j.jakartaee-stable",
    displayName: "Jakarta Stable APIs",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "envinject",
    ],
  },
}
