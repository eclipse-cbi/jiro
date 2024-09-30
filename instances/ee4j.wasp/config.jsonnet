{
  project+: {
    fullName: "ee4j.wasp",
    displayName: "Eclipse WaSP",
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c56,c55",
}
