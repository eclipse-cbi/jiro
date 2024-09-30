{
  project+: {
    fullName: "ee4j.jsonb",
    displayName: "Jakarta JSON Binding",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c44,c34",
}
