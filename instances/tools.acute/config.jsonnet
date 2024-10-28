{
  project+: {
    fullName: "tools.acute",
    displayName: "Eclipse aCute"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c28,c17",
}
