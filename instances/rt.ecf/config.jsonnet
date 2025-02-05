{
  project+: {
    fullName: "rt.ecf",
    displayName: "Eclipse Communication Framework"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c35,c25",
}
