{
  project+: {
    fullName: "rt.gemini",
    displayName: "Eclipse Gemini",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger"
    ]
  },
  seLinuxLevel: "s0:c40,c5",
}
