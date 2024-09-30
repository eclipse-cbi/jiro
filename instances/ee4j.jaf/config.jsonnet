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
  seLinuxLevel: "s0:c42,c24",
}
