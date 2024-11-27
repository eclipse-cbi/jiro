{
  project+: {
    fullName: "ee4j.mail",
    displayName: "Jakarta Mail",
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c47,c29",
}
