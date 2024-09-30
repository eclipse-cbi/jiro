{
  project+: {
    fullName: "ee4j.ejb",
    displayName: "Jakarta Enterprise Beans"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  seLinuxLevel: "s0:c37,c19",
}
