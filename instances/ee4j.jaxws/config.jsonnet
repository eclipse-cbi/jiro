{
  project+: {
    fullName: "ee4j.jaxws",
    displayName: "Jakarta XML Web Services",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c43,c27",
}
