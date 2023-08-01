{
  project+: {
    fullName: "iot.4diac",
    displayName: "Eclipse 4diac",
  },
  jenkins+: {
    plugins+: [
      "cmakebuilder",
      "copyartifact",
      "cppcheck",
      "gerrit-trigger",
    ],
  },
}
