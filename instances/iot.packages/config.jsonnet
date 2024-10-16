{
  project+: {
    fullName: "iot.packages",
    displayName: "Eclipse IoT Packages"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  },
  seLinuxLevel: "s0:c50,c45",
}
