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
  seLinuxLevel: "s0:c42,c39",
}
