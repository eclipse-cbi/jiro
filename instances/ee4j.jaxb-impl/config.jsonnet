{
  project+: {
    fullName: "ee4j.jaxb-impl",
    displayName: "Eclipse Implementation of JAXB",
  },
  jenkins+: {
    plugins+: [
      "envinject",
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c43,c12",
}
