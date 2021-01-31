{
  project+: {
    fullName: "technology.openk-usermodules",
    displayName: "Eclipse openK User Modules"
  },
  jenkins+: {
    plugins+: [
      "nodejs",
      "copyartifact",
      "metrics",
    ],
  },
}
